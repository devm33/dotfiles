import XMonad
import XMonad.Layout.NoBorders (noBorders)
import XMonad.Layout.Reflect
import XMonad.Layout.Fullscreen
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Actions.GridSelect
import XMonad.Actions.CycleWS
-- import XMonad.Actions.Navigation2D
import XMonad.Util.EZConfig (additionalKeysP, additionalMouseBindings)
import XMonad.Config.Gnome
import qualified XMonad.StackSet as W
import XMonad.Hooks.SetWMName
import System.Exit


main = xmonad myConfig

myConfig = gnomeConfig { modMask = mod4Mask -- use the super key

-- , terminal = "gnome-terminal"

-- Note: commented out all of the fullscreen logic because it was causing
-- google-chrome to behave very strangely: mis-firing painting, leaving
-- remnants, flashing, etc.
-- Note: Note: this might not have been due to fullscreen logic, testing
-- out startup hook below, can maybe readd fullscreen logic if desired

, startupHook =
    do startupHook gnomeConfig
       -- Custom startup hooks:
       spawn "xcompmgr -a"
       spawn "setxkbmap -option caps:super"
       spawn "xcape -e 'Super_L=Escape'"
       setWMName "LG3D"

, layoutHook =
    noBorders $ -- remove borders
    avoidStruts $ -- dont cover gnome panel
    -- fullscreenFull $  -- but allow fullscreen windows to cover panel
    layoutHook gnomeConfig

, manageHook = composeAll [ manageHook gnomeConfig
                          -- necessary for fullscreen windows to cover
                          -- the gnome-panel
                          -- , isFullscreen --> doFullFloat
                          ]

, handleEventHook = composeAll [ handleEventHook gnomeConfig
                               -- necessary for fullscreen windows
                               -- , fullscreenEventHook
                               ]

-- custom key bindings and mouse bindings
} `additionalKeysP` myKeys `additionalMouseBindings` myButtons

myKeys = [ ("M-g", goToSelected defaultGSConfig)
         , ("M-S-n", sendMessage NextLayout)
         , ("M-s", spawn "gnome-screensaver-command -l")
         , ("M-o", spawn "gmrun")
         , ("M-p", spawn "gnome-terminal -e prodaccess")
         , ("M-S-p", gnomeRun)
         , ("M-<Space>", spawn "gmrun")
         , ("M-c", spawn "google-chrome --profile-directory=\"Default\"")
         , ("M-m", spawn "google-chrome --profile-directory=\"Profile 1\"")
         , ("M-f", spawn "firefox")
         , ("M-a", spawn "gnome-terminal")
         , ("M-i", spawn "/opt/intellij-ue-stable/bin/idea.sh")
         , ("M-<Return>", spawn "gnome-terminal")
         , ("M-S-<Return>", windows W.swapMaster)
         , ("C-<Print>", spawn "gnome-screenshot -i")
         , ("M-x", kill)
         , ("M-S-x", io (exitWith ExitSuccess))
         , ("M-S-h", spawn "halt")
         , ("M-S-r", spawn "reboot")
         , ("M-<Right>", nextWS)
         , ("M-<Left>", prevWS)
         , ("M-S-<Right>", shiftToNext >> nextWS)
         , ("M-S-<Left>", shiftToPrev >> prevWS)
         , ("M-<Tab>", toggleWS)
         , ("M-[", onScreen 0 W.view)
         , ("M-]", onScreen 1 W.view)
         , ("M-S-[", onScreen 0 W.shift)
         , ("M-S-]", onScreen 1 W.shift)
         , ("M-<F4>", spawn "google-chrome --new-window \"https://meet.google.com\"")
         , ("M-=", spawn "amixer -D pulse set Master 5%+")
         , ("M--", spawn "amixer -D pulse set Master 5%-")
         ]

myButtons = [((0, 10), (\_ -> toggleWS))]

onScreen d f = do mws <- screenWorkspace d
                  case mws of
                      Nothing -> return ()
                      Just ws -> windows (f ws)
