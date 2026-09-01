#Requires -RunAsAdministrator
<#
.SYNOPSIS
Sets up an SSH-accessible WSL devbox, GitHub authentication, and dotfiles.

.EXAMPLE
.\setup-devbox.ps1 -LinuxUser devrajmehta

.EXAMPLE
.\setup-devbox.ps1 -LinuxUser devrajmehta -SshPublicKeyPath C:\Users\me\.ssh\id_ed25519_2.pub

.EXAMPLE
.\setup-devbox.ps1 -WslLocation Q:\WSL\Ubuntu -LinuxUser devrajmehta
#>
[CmdletBinding()]
param(
    [string]$Distro = "Ubuntu",
    [string]$WslLocation,
    [string]$LinuxUser = ([string]$env:USERNAME).ToLowerInvariant(),
    [string]$TunnelId,
    [string]$SshPublicKeyPath,
    [string]$SshPublicKey
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$env:WSL_UTF8 = "1"

$windowsPrincipal = [Security.Principal.WindowsPrincipal]::new(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)
if (-not $windowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Administrator privileges are required. Open Windows Terminal as administrator and rerun this command."
}

if ($LinuxUser -notmatch '^[a-z_][a-z0-9_-]*$') {
    throw "LinuxUser must contain only lowercase letters, numbers, underscores, and hyphens."
}

if ($TunnelId -and $TunnelId -notmatch '^[a-z0-9][a-z0-9-]{2,59}$') {
    throw "TunnelId must be 3-60 lowercase letters, numbers, or hyphens."
}

function Invoke-WslScript {
    param(
        [Parameter(Mandatory)]
        [string]$Script,
        [string]$User = "root"
    )

    $encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Script))
    & wsl.exe --distribution $Distro --user $User --exec bash -lc "printf '%s' '$encoded' | base64 --decode | bash"
    if ($LASTEXITCODE -ne 0) {
        throw "A command in WSL failed with exit code $LASTEXITCODE."
    }
}

function Get-InstalledDistros {
    @(
        & wsl.exe --list --quiet 2>$null |
            ForEach-Object { $_.Replace("`0", "").Trim().TrimStart([char]0xFEFF) } |
            Where-Object { $_ }
    )
}

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    throw "wsl.exe is unavailable. This script requires Windows 10 2004+ or Windows 11."
}

if (-not $WslLocation -and (Test-Path "Q:\" -PathType Container)) {
    $WslLocation = Join-Path "Q:\WSL" $Distro
}

if ($Distro -notin (Get-InstalledDistros)) {
    Write-Host "Installing WSL and $Distro..."
    $installArguments = @("--install", "--distribution", $Distro, "--no-launch")
    if ($WslLocation) {
        $installArguments += @("--location", $WslLocation)
        Write-Host "WSL storage location: $WslLocation"
    }
    & wsl.exe @installArguments

    if ($Distro -notin (Get-InstalledDistros)) {
        Write-Warning "Windows must restart to finish installing WSL. Reboot, then run this script again."
        exit 3010
    }
}

& wsl.exe --update
if ($LASTEXITCODE -ne 0) {
    throw "Could not update WSL. Reboot Windows and rerun this script."
}

$distroLine = & wsl.exe --list --verbose |
    Where-Object { $_ -match [regex]::Escape($Distro) } |
    Select-Object -First 1
$installedVersion = [regex]::Match([string]$distroLine, '([12])\s*$').Groups[1].Value
if ($installedVersion -ne "2") {
    & wsl.exe --set-version $Distro 2
    if ($LASTEXITCODE -ne 0) {
        throw "Could not configure $Distro to use WSL 2. Reboot Windows and rerun this script."
    }
}

function Test-WslDistro {
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    & wsl.exe --distribution $Distro --user root --exec /bin/true *> $null
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorActionPreference
    return $exitCode -eq 0
}

function Restart-WslService {
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [int]$TimeoutSeconds = 45
    )

    $restartJob = Start-Job -ScriptBlock {
        param($ServiceName)
        Restart-Service $ServiceName -Force -ErrorAction Stop
    } -ArgumentList $Name

    try {
        if (-not (Wait-Job $restartJob -Timeout $TimeoutSeconds)) {
            Stop-Job $restartJob
            return $false
        }

        Receive-Job $restartJob -ErrorAction Stop | Out-Null
        return $restartJob.State -eq "Completed"
    }
    catch {
        return $false
    }
    finally {
        Remove-Job $restartJob -Force
    }
}

if (-not (Test-WslDistro)) {
    Write-Host "WSL is not responding. Restarting its Windows service..."
    $wslService = Get-Service WslService -ErrorAction SilentlyContinue
    if (-not $wslService) {
        $wslService = Get-Service LxssManager -ErrorAction SilentlyContinue
    }
    if (-not $wslService) {
        throw "WSL is not responding and its Windows service could not be found. Reboot Windows and rerun setup."
    }

    if (-not (Restart-WslService -Name $wslService.Name)) {
        throw "Timed out restarting $($wslService.Name). Reboot Windows and rerun setup."
    }
    Start-Sleep -Seconds 5
    if (-not (Test-WslDistro)) {
        throw "WSL is still not responding after restarting $($wslService.Name). Reboot Windows and rerun setup."
    }
}

function Read-GitHubToken {
    Write-Host "GitHub authentication requires a classic personal access token with these scopes:"
    Write-Host "  repo, read:org, gist, admin:public_key, admin:ssh_signing_key"
    $token = Read-Host "Paste the GitHub token (input is hidden)" -AsSecureString
    if ($token.Length -eq 0) {
        throw "A GitHub personal access token is required."
    }
    return $token
}

$githubToken = $null
$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
& wsl.exe --distribution $Distro --user $LinuxUser --exec env `
    "DBUS_SESSION_BUS_ADDRESS=unix:path=/dev/null" `
    "GNOME_KEYRING_CONTROL=" `
    gh auth token --hostname github.com *> $null
$hasCachedGitHubAuth = $LASTEXITCODE -eq 0
$ErrorActionPreference = $previousErrorActionPreference
if ($hasCachedGitHubAuth) {
    Write-Host "Reusing the GitHub credential already cached in WSL."
}
else {
    $githubToken = Read-GitHubToken
}

$hasAuthorizedKey = $false
if (-not $SshPublicKey -and -not $SshPublicKeyPath) {
    & wsl.exe --distribution $Distro --user root --exec test -s "/home/$LinuxUser/.ssh/authorized_keys"
    $hasAuthorizedKey = $LASTEXITCODE -eq 0
}

if (-not $SshPublicKey -and -not $hasAuthorizedKey) {
    if (-not $SshPublicKeyPath) {
        $candidates = @(
            (Join-Path $HOME ".ssh\id_ed25519_2.pub"),
            (Join-Path $HOME ".ssh\id_ed25519.pub")
        )
        $SshPublicKeyPath = $candidates |
            Where-Object { Test-Path $_ -PathType Leaf } |
            Select-Object -First 1
    }

    if ($SshPublicKeyPath) {
        $SshPublicKey = (Get-Content -Raw $SshPublicKeyPath).Trim()
    }
    else {
        $SshPublicKey = (Read-Host "Paste the SSH public key allowed to access this devbox").Trim()
    }
}

if ($SshPublicKey -and $SshPublicKey -notmatch '^ssh-(ed25519|rsa|ecdsa-[^ ]+) [A-Za-z0-9+/=]+(?: .*)?$') {
    throw "The supplied SSH public key is not in a recognized OpenSSH public-key format."
}

if ($hasAuthorizedKey) {
    Write-Host "Reusing the SSH public key already configured in WSL."
    $publicKeyBase64 = ""
}
else {
    $publicKeyBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($SshPublicKey))
}
$bootstrap = @'
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

linux_user="__LINUX_USER__"
public_key_base64="__PUBLIC_KEY_BASE64__"

apt-get update -y
apt-get install -y \
  ca-certificates \
  curl \
  dbus \
  git \
  gnome-keyring \
  libicu-dev \
  libsecret-1-0 \
  locales \
  openssh-server \
  sudo \
  systemd \
  systemd-sysv

install -d -m 0755 /etc/apt/keyrings /etc/apt/sources.list.d
github_keyring=$(mktemp)
curl --fail --silent --show-error --location \
  --output "$github_keyring" \
  https://cli.github.com/packages/githubcli-archive-keyring.gpg
install -m 0644 "$github_keyring" /etc/apt/keyrings/githubcli-archive-keyring.gpg
rm -f "$github_keyring"
printf '%s\n' \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  >/etc/apt/sources.list.d/github-cli.list
apt-get update -y
apt-get install -y gh

sed -i -E 's/^# *en_US\.UTF-8 +UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
if ! grep -Eq '^en_US\.UTF-8[[:space:]]+UTF-8' /etc/locale.gen; then
  printf '%s\n' 'en_US.UTF-8 UTF-8' >>/etc/locale.gen
fi
locale-gen
update-locale LANG=en_US.UTF-8

if ! id "$linux_user" >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash "$linux_user"
fi
usermod --append --groups sudo "$linux_user"
printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$linux_user" >"/etc/sudoers.d/90-$linux_user"
chmod 0440 "/etc/sudoers.d/90-$linux_user"

home_dir="/home/$linux_user"
install -d -m 0700 -o "$linux_user" -g "$linux_user" "$home_dir/.config"
install -d -m 0700 -o "$linux_user" -g "$linux_user" "$home_dir/.ssh"
touch "$home_dir/.ssh/authorized_keys"
if [[ -n "$public_key_base64" ]]; then
  public_key=$(printf '%s' "$public_key_base64" | base64 --decode)
  if ! grep -qxF "$public_key" "$home_dir/.ssh/authorized_keys"; then
    printf '%s\n' "$public_key" >>"$home_dir/.ssh/authorized_keys"
  fi
fi
chown "$linux_user:$linux_user" "$home_dir/.ssh/authorized_keys"
chmod 0600 "$home_dir/.ssh/authorized_keys"

install -d -m 0755 /etc/ssh/sshd_config.d
if ! grep -Eq '^[[:space:]]*Include[[:space:]]+/etc/ssh/sshd_config\.d/\*\.conf' /etc/ssh/sshd_config; then
  sed -i '1iInclude /etc/ssh/sshd_config.d/*.conf' /etc/ssh/sshd_config
fi
cat >/etc/ssh/sshd_config.d/60-devbox.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
EOF
ssh-keygen -A
sshd -t
systemctl enable ssh.service || true

cat >/etc/wsl.conf <<EOF
[boot]
systemd=true

[user]
default=$linux_user
EOF

install -d -m 0755 -o "$linux_user" -g "$linux_user" "$home_dir/bin"
case "$(uname -m)" in
  x86_64)
    devtunnel_url="https://tunnelsassetsprod.blob.core.windows.net/cli/linux-x64-devtunnel"
    ;;
  arm64|aarch64)
    devtunnel_url="https://tunnelsassetsprod.blob.core.windows.net/cli/linux-arm64-devtunnel"
    ;;
  *)
    echo "Unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac
devtunnel_tmp=$(mktemp "$home_dir/bin/.devtunnel.XXXXXX")
trap 'rm -f "$devtunnel_tmp"' EXIT
curl --fail --silent --show-error --location \
  --output "$devtunnel_tmp" "$devtunnel_url"
chown "$linux_user:$linux_user" "$devtunnel_tmp"
chmod 0755 "$devtunnel_tmp"
mv -f "$devtunnel_tmp" "$home_dir/bin/devtunnel"
trap - EXIT

cat >"$home_dir/bin/devtunnel-session" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

exec dbus-run-session -- bash -c '
  eval "$(gnome-keyring-daemon --start --components=secrets 2>/dev/null)"
  printf "\n" | gnome-keyring-daemon --unlock >/dev/null 2>&1
  exec "$@"
' bash "$HOME/bin/devtunnel" "$@"
EOF
chown "$linux_user:$linux_user" "$home_dir/bin/devtunnel-session"
chmod 0755 "$home_dir/bin/devtunnel-session"
"$home_dir/bin/devtunnel" --version
'@
$bootstrap = $bootstrap.Replace("__LINUX_USER__", $LinuxUser)
$bootstrap = $bootstrap.Replace("__PUBLIC_KEY_BASE64__", $publicKeyBase64)
Invoke-WslScript -Script $bootstrap

Write-Host "Restarting WSL to enable systemd..."
& wsl.exe --terminate $Distro
Start-Sleep -Seconds 2

$systemdState = (& wsl.exe --distribution $Distro --user root --exec systemctl is-system-running --wait 2>$null |
    Out-String).Trim()
if ($systemdState -notin @("running", "degraded")) {
    throw "systemd did not start correctly in $Distro."
}
& wsl.exe --distribution $Distro --user root --exec systemctl start ssh.service
if ($LASTEXITCODE -ne 0) {
    throw "OpenSSH failed to start in $Distro."
}

$devtunnel = "/home/$LinuxUser/bin/devtunnel-session"
$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$loginStatus = (& wsl.exe --distribution $Distro --user $LinuxUser --exec $devtunnel user show 2>&1 |
    Out-String)
$loginStatusExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference
if ($loginStatusExitCode -ne 0 -or $loginStatus -notmatch "Logged in as") {
    Write-Host "Dev tunnels login is interactive. Complete the device-code flow when prompted."
    & wsl.exe --distribution $Distro --user $LinuxUser --exec $devtunnel user login --use-device-code-auth
    if ($LASTEXITCODE -ne 0) {
        throw "Dev tunnels login failed."
    }
}
else {
    Write-Host ($loginStatus.Trim())
}

$storedTunnelId = (& wsl.exe --distribution $Distro --user $LinuxUser --exec bash -lc `
    'cat "$HOME/.config/devbox/tunnel-id" 2>/dev/null || true' | Out-String).Trim()

if (-not $TunnelId) {
    if ($storedTunnelId) {
        $TunnelId = $storedTunnelId
    }
    else {
        $machineSlug = ([string]$env:COMPUTERNAME).ToLowerInvariant() -replace '[^a-z0-9-]', '-'
        $machineSlug = $machineSlug.Trim("-")
        if ($machineSlug.Length -gt 35) {
            $machineSlug = $machineSlug.Substring(0, 35).TrimEnd("-")
        }
        $TunnelId = "devbox-$machineSlug-$([Guid]::NewGuid().ToString('N').Substring(0, 8))"
    }
}

Write-Host "Configuring dev tunnel $TunnelId..."
$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$tunnelStatus = (& wsl.exe --distribution $Distro --user $LinuxUser --exec $devtunnel show $TunnelId 2>&1 |
    Out-String)
$tunnelStatusExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference
if ($tunnelStatusExitCode -ne 0 -and $tunnelStatus -match "Tunnel not found") {
    & wsl.exe --distribution $Distro --user $LinuxUser --exec $devtunnel create $TunnelId --expiration 30d
    if ($LASTEXITCODE -ne 0) {
        throw "Could not create dev tunnel $TunnelId."
    }
}
elseif ($tunnelStatusExitCode -ne 0) {
    throw "Could not inspect dev tunnel $TunnelId`: $($tunnelStatus.Trim())"
}
else {
    Write-Host ($tunnelStatus.Trim())
}

& wsl.exe --distribution $Distro --user $LinuxUser --exec $devtunnel port show $TunnelId --port-number 22
if ($LASTEXITCODE -ne 0) {
    & wsl.exe --distribution $Distro --user $LinuxUser --exec $devtunnel port create $TunnelId --port-number 22
    if ($LASTEXITCODE -ne 0) {
        throw "Could not add SSH port 22 to dev tunnel $TunnelId."
    }
}

$serviceSetup = @'
set -euo pipefail

linux_user="__LINUX_USER__"
tunnel_id="__TUNNEL_ID__"
home_dir="/home/$linux_user"

install -d -m 0700 -o "$linux_user" -g "$linux_user" "$home_dir/.config"
install -d -m 0700 -o "$linux_user" -g "$linux_user" "$home_dir/.config/devbox"
printf '%s\n' "$tunnel_id" >"$home_dir/.config/devbox/tunnel-id"
chown "$linux_user:$linux_user" "$home_dir/.config/devbox/tunnel-id"

cat >/etc/systemd/system/devtunnel-ssh.service <<EOF
[Unit]
Description=Dev tunnel for WSL SSH
After=network-online.target ssh.service
Wants=network-online.target
Requires=ssh.service
StartLimitIntervalSec=0

[Service]
Type=simple
User=$linux_user
Environment=HOME=$home_dir
Environment=PATH=$home_dir/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=$home_dir/bin/devtunnel-session host $tunnel_id
Restart=always
RestartSec=5
RuntimeMaxSec=6h
TimeoutStopSec=15

[Install]
WantedBy=multi-user.target
EOF

cat >/etc/systemd/system/devtunnel-refresh.service <<EOF
[Unit]
Description=Renew the WSL SSH dev tunnel expiration
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=$linux_user
Environment=HOME=$home_dir
ExecStart=$home_dir/bin/devtunnel-session update $tunnel_id --expiration 30d
EOF

cat >/etc/systemd/system/devtunnel-refresh.timer <<'EOF'
[Unit]
Description=Renew the WSL SSH dev tunnel daily

[Timer]
OnBootSec=5m
OnUnitActiveSec=1d
Persistent=true
RandomizedDelaySec=10m

[Install]
WantedBy=timers.target
EOF

cat >/usr/local/sbin/devbox-keepalive <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

systemctl start ssh.service devtunnel-ssh.service devtunnel-refresh.timer
exec /usr/bin/sleep infinity
EOF
chmod 0755 /usr/local/sbin/devbox-keepalive

systemctl daemon-reload
systemctl enable --now ssh.service devtunnel-refresh.timer
systemctl enable devtunnel-ssh.service
systemctl restart devtunnel-ssh.service
systemctl --no-pager --full status devtunnel-ssh.service
'@
$serviceSetup = $serviceSetup.Replace("__LINUX_USER__", $LinuxUser)
$serviceSetup = $serviceSetup.Replace("__TUNNEL_ID__", $TunnelId)
Invoke-WslScript -Script $serviceSetup

$taskName = "Devbox WSL tunnel ($Distro)"
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

$watchdogDirectory = Join-Path $env:LOCALAPPDATA "Devbox"
New-Item -ItemType Directory -Force $watchdogDirectory | Out-Null
$safeDistroName = $Distro -replace '[^A-Za-z0-9_.-]', '-'
$watchdogPath = Join-Path $watchdogDirectory "watchdog-$safeDistroName.ps1"
$mutexName = "Local\DevboxWslWatchdog-$safeDistroName"
$distroLiteral = $Distro.Replace("'", "''")

$watchdogScript = @'
$createdNew = $false
try {
    $mutex = New-Object System.Threading.Mutex($true, '__MUTEX_NAME__', [ref]$createdNew)
}
catch [System.UnauthorizedAccessException] {
    # An elevated copy already owns the cross-integrity mutex.
    exit 0
}
if (-not $createdNew) {
    exit 0
}

while ($true) {
    & "$env:SystemRoot\System32\wsl.exe" `
        --distribution '__DISTRO__' `
        --user root `
        --exec /usr/local/sbin/devbox-keepalive
    Start-Sleep -Seconds 5
}
'@
$watchdogScript = $watchdogScript.Replace("__MUTEX_NAME__", $mutexName)
$watchdogScript = $watchdogScript.Replace("__DISTRO__", $distroLiteral)
Set-Content -Path $watchdogPath -Value $watchdogScript -Encoding UTF8

$startupDirectory = [Environment]::GetFolderPath("Startup")
$launcherPath = Join-Path $startupDirectory "Devbox WSL Watchdog.vbs"
$vbsWatchdogPath = $watchdogPath.Replace('"', '""')
$launcherScript = @"
Set shell = CreateObject("WScript.Shell")
shell.Run "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File ""$vbsWatchdogPath""", 0, False
"@
Set-Content -Path $launcherPath -Value $launcherScript -Encoding ASCII
Start-Process "$env:SystemRoot\System32\wscript.exe" -ArgumentList "`"$launcherPath`""

$healthCheckPath = Join-Path $watchdogDirectory "health-$safeDistroName.ps1"
$healthLogPath = Join-Path $watchdogDirectory "health-$safeDistroName.log"
$healthScript = @'
$probeArguments = '--distribution "__DISTRO__" --user root --exec /bin/true'
$probe = Start-Process `
    -FilePath "$env:SystemRoot\System32\wsl.exe" `
    -ArgumentList $probeArguments `
    -WindowStyle Hidden `
    -PassThru

$restartWsl = $false
if (-not $probe.WaitForExit(60000)) {
    Stop-Process -Id $probe.Id -Force -ErrorAction SilentlyContinue
    Add-Content '__HEALTH_LOG__' "$(Get-Date -Format o) WSL probe timed out."
    $restartWsl = $true
}
elseif ($probe.ExitCode -ne 0) {
    Add-Content '__HEALTH_LOG__' "$(Get-Date -Format o) WSL probe exited with code $($probe.ExitCode)."
    $restartWsl = $true
}

if ($restartWsl) {
    $wslService = Get-Service WslService -ErrorAction SilentlyContinue
    if (-not $wslService) {
        $wslService = Get-Service LxssManager -ErrorAction SilentlyContinue
    }
    if ($wslService) {
        $restartJob = Start-Job -ScriptBlock {
            param($ServiceName)
            Restart-Service $ServiceName -Force -ErrorAction Stop
        } -ArgumentList $wslService.Name
        if (-not (Wait-Job $restartJob -Timeout 45)) {
            Stop-Job $restartJob
            Add-Content '__HEALTH_LOG__' "$(Get-Date -Format o) Timed out restarting $($wslService.Name)."
        }
        elseif ($restartJob.State -ne 'Completed') {
            Add-Content '__HEALTH_LOG__' "$(Get-Date -Format o) Failed restarting $($wslService.Name)."
        }
        Remove-Job $restartJob -Force
        Start-Sleep -Seconds 5
    }
}

$watchdog = Get-CimInstance Win32_Process |
    Where-Object CommandLine -Like '*watchdog-__SAFE_DISTRO__.ps1*' |
    Select-Object -First 1
if (-not $watchdog) {
    Start-Process "$env:SystemRoot\System32\wscript.exe" -ArgumentList '"__LAUNCHER_PATH__"'
}
'@
$healthScript = $healthScript.Replace("__DISTRO__", $Distro.Replace('"', '\"'))
$healthScript = $healthScript.Replace("__SAFE_DISTRO__", $safeDistroName)
$healthScript = $healthScript.Replace("__HEALTH_LOG__", $healthLogPath.Replace("'", "''"))
$healthScript = $healthScript.Replace("__LAUNCHER_PATH__", $launcherPath.Replace('"', '""'))
Set-Content -Path $healthCheckPath -Value $healthScript -Encoding UTF8

$healthTaskName = "Devbox WSL health ($Distro)"
$windowsIdentity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
$healthPrincipal = New-ScheduledTaskPrincipal `
    -UserId $windowsIdentity `
    -LogonType Interactive `
    -RunLevel Highest
$healthAction = New-ScheduledTaskAction `
    -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -Argument "-NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$healthCheckPath`""
$healthLogonTrigger = New-ScheduledTaskTrigger -AtLogOn -User $windowsIdentity
$healthTimerTrigger = New-ScheduledTaskTrigger `
    -Once `
    -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes 5)
$healthSettings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 3)

Register-ScheduledTask `
    -TaskName $healthTaskName `
    -Action $healthAction `
    -Principal $healthPrincipal `
    -Trigger @($healthLogonTrigger, $healthTimerTrigger) `
    -Settings $healthSettings `
    -Description "Recovers a hung WSL service and restarts the devbox watchdog." `
    -Force | Out-Null

$githubKeySetup = @'
set -euo pipefail

install -d -m 0700 "$HOME/.ssh"
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  ssh-keygen \
    -t ed25519 \
    -N "" \
    -C "$(whoami)@$(hostname)-wsl" \
    -f "$HOME/.ssh/id_ed25519"
fi
if [[ ! -f "$HOME/.ssh/id_ed25519.pub" ]]; then
  ssh-keygen -y -f "$HOME/.ssh/id_ed25519" >"$HOME/.ssh/id_ed25519.pub"
fi
chmod 0600 "$HOME/.ssh/id_ed25519"
chmod 0644 "$HOME/.ssh/id_ed25519.pub"
'@
Invoke-WslScript -Script $githubKeySetup -User $LinuxUser

$machineSuffix = (($env:COMPUTERNAME -split "-")[-1]).ToLowerInvariant()
$githubKeyTitle = "wsl devbox $machineSuffix"

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
& wsl.exe --distribution $Distro --user $LinuxUser --exec env `
    "DBUS_SESSION_BUS_ADDRESS=unix:path=/dev/null" `
    "GNOME_KEYRING_CONTROL=" `
    gh auth status --hostname github.com
$githubAuthStatusExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference
if ($githubAuthStatusExitCode -ne 0) {
    if (-not $githubToken) {
        Write-Warning "The cached GitHub credential is no longer valid."
        $githubToken = Read-GitHubToken
    }

    $tokenPointer = [IntPtr]::Zero
    $plainTextToken = $null
    $githubLoginExitCode = -1
    $previousErrorActionPreference = $ErrorActionPreference
    try {
        $tokenPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($githubToken)
        $plainTextToken = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($tokenPointer)

        $ErrorActionPreference = "Continue"
        $plainTextToken | & wsl.exe --distribution $Distro --user $LinuxUser --exec env `
            "DBUS_SESSION_BUS_ADDRESS=unix:path=/dev/null" `
            "GNOME_KEYRING_CONTROL=" `
            gh auth login `
            --hostname github.com `
            --git-protocol ssh `
            --insecure-storage `
            --skip-ssh-key `
            --with-token
        $githubLoginExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
        $plainTextToken = $null
        $githubToken = $null
        if ($tokenPointer -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($tokenPointer)
        }
    }

    if ($githubLoginExitCode -ne 0) {
        throw "GitHub CLI login failed."
    }
}
& wsl.exe --distribution $Distro --user $LinuxUser --exec bash -lc `
    'if [ -f "$HOME/.config/gh/hosts.yml" ]; then chmod 600 "$HOME/.config/gh/hosts.yml"; fi'
if ($LASTEXITCODE -ne 0) {
    throw "Could not secure the GitHub CLI credentials file."
}

$githubPublicKey = (& wsl.exe --distribution $Distro --user $LinuxUser --exec bash -lc `
    'awk ''{print $1 " " $2}'' "$HOME/.ssh/id_ed25519.pub"' | Out-String).Trim()
if (-not $githubPublicKey) {
    throw "Could not read the generated GitHub SSH public key."
}

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$githubKeysOutput = (& wsl.exe --distribution $Distro --user $LinuxUser --exec env `
    "DBUS_SESSION_BUS_ADDRESS=unix:path=/dev/null" `
    "GNOME_KEYRING_CONTROL=" `
    gh api `
    user/keys `
    --paginate `
    --jq '.[].key' 2>&1 | Out-String)
$githubKeysExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference

$hasPublicKeyScope = $githubKeysExitCode -eq 0
if (
    $githubKeysExitCode -ne 0 -and
    $githubKeysOutput -notmatch '(?i)(scope|permission|forbidden|HTTP 403|not accessible)'
) {
    throw "Could not list GitHub SSH keys: $($githubKeysOutput.Trim())"
}

$githubKeyExists = $false
if ($githubKeysExitCode -eq 0) {
    $githubKeyExists = @($githubKeysOutput -split '\r?\n') -contains $githubPublicKey
}

if (-not $githubKeyExists) {
    if (-not $hasPublicKeyScope) {
        throw "The GitHub token cannot manage SSH keys. Grant it the admin:public_key scope and rerun setup."
    }

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $addKeyOutput = (& wsl.exe --distribution $Distro --user $LinuxUser --exec env `
        "DBUS_SESSION_BUS_ADDRESS=unix:path=/dev/null" `
        "GNOME_KEYRING_CONTROL=" `
        gh ssh-key add `
        "/home/$LinuxUser/.ssh/id_ed25519.pub" `
        --title $githubKeyTitle 2>&1 | Out-String)
    $addKeyExitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorActionPreference
    if ($addKeyExitCode -ne 0 -and $addKeyOutput -notmatch '(?i)(already in use|key already exists)') {
        throw "Could not add the generated SSH key to GitHub: $($addKeyOutput.Trim())"
    }
}

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$githubSigningKeysOutput = (& wsl.exe --distribution $Distro --user $LinuxUser --exec env `
    "DBUS_SESSION_BUS_ADDRESS=unix:path=/dev/null" `
    "GNOME_KEYRING_CONTROL=" `
    gh api `
    user/ssh_signing_keys `
    --paginate `
    --jq '.[].key' 2>&1 | Out-String)
$githubSigningKeysExitCode = $LASTEXITCODE
$ErrorActionPreference = $previousErrorActionPreference

$hasSigningKeyScope = $githubSigningKeysExitCode -eq 0
if (
    $githubSigningKeysExitCode -ne 0 -and
    $githubSigningKeysOutput -notmatch '(?i)(scope|permission|forbidden|HTTP 403|not accessible)'
) {
    throw "Could not list GitHub SSH signing keys: $($githubSigningKeysOutput.Trim())"
}

$githubSigningKeyExists = $false
if ($githubSigningKeysExitCode -eq 0) {
    $githubSigningKeyExists = @($githubSigningKeysOutput -split '\r?\n') -contains $githubPublicKey
}

if (-not $githubSigningKeyExists) {
    if (-not $hasSigningKeyScope) {
        throw "The GitHub token cannot manage SSH signing keys. Grant it the admin:ssh_signing_key scope and rerun setup."
    }

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $addSigningKeyOutput = (& wsl.exe --distribution $Distro --user $LinuxUser --exec env `
        "DBUS_SESSION_BUS_ADDRESS=unix:path=/dev/null" `
        "GNOME_KEYRING_CONTROL=" `
        gh ssh-key add `
        "/home/$LinuxUser/.ssh/id_ed25519.pub" `
        --type signing `
        --title "$githubKeyTitle signing" 2>&1 | Out-String)
    $addSigningKeyExitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorActionPreference
    if (
        $addSigningKeyExitCode -ne 0 -and
        $addSigningKeyOutput -notmatch '(?i)(already in use|key already exists)'
    ) {
        throw "Could not add the GitHub SSH signing key: $($addSigningKeyOutput.Trim())"
    }
}

$workDotfilesSetup = @'
set -euo pipefail

work_repo="$HOME/code/dotfiles-work"
mkdir -p "$HOME/code"
export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"

if [[ -d "$work_repo/.git" ]]; then
  git -C "$work_repo" pull --ff-only
elif [[ -e "$work_repo" ]]; then
  echo "$work_repo already exists but is not a git repository" >&2
  exit 1
else
  git clone git@github.com:devm33/dotfiles-work.git "$work_repo"
fi
'@
Write-Host "Installing work dotfiles..."
Invoke-WslScript -Script $workDotfilesSetup -User $LinuxUser

Write-Host "Installing dotfiles..."
# Run directly so any downstream interactive steps retain Windows Terminal input.
& wsl.exe --distribution $Distro --user $LinuxUser --exec bash -lc `
    'export DOTFILES_HOST=github; export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"; bash -c "$(curl -fsSL https://raw.githubusercontent.com/devm33/dotfiles/main/install/ubuntu.sh)"'
if ($LASTEXITCODE -ne 0) {
    throw "Dotfiles installation failed."
}

Start-ScheduledTask -TaskName $healthTaskName

Write-Host ""
Write-Host "Devbox setup complete." -ForegroundColor Green
Write-Host "Tunnel ID: $TunnelId"
Write-Host "Linux user: $LinuxUser"
Write-Host "Client command: devtunnel connect $TunnelId"
Write-Host "Service logs: wsl -d `"$Distro`" -u root -- journalctl -u devtunnel-ssh.service -f"
Write-Host "Watchdog: $watchdogPath"
Write-Host "Health check: $healthCheckPath"
