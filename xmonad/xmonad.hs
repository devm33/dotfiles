import XMonad
import XMonad.Layout.NoBorders (noBorders)
import XMonad.Layout.Reflect
import XMonad.Layout.Fullscreen
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Actions.GridSelect
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Config.Gnome

main = xmonad myConfig

myConfig = gnomeConfig { modMask = mod4Mask -- use the super key

, terminal = "gnome-terminal"

, layoutHook =
    noBorders $ -- remove borders
    fullscreenFull $  -- allow fullscreen windows to cover panel
    layoutHook gnomeConfig

, manageHook = composeAll [ manageHook gnomeConfig
                          , (className =? "Pidgin" <&&> title =? "Buddy List")  --> doFloat
                          , isFullscreen --> doFullFloat
                          ]

, handleEventHook = composeAll [ handleEventHook gnomeConfig
                               -- notice when Firefox goes fullscreen
                               , fullscreenEventHook
                               ]

-- custom key bindings
} `additionalKeysP` myKeys

myKeys = [ ("M-g", goToSelected defaultGSConfig)
         , ("M-s", spawn "gnome-screensaver-command -l")
         , ("M-o", spawn "gmrun")
         , ("M-b", spawn "google-chrome")
         , ("M-f", spawn "firefox")
         , ("M-a", spawn "gnome-terminal")
         , ("M-c", spawn "pidgin")
         , ("M-x", kill)
         , ("M-v", spawn "/opt/cisco/anyconnect/bin/vpnui")
         , ("M-m", spawn "VirtualBox")
         , ("M-S-h", spawn "halt")
         , ("M-S-r", spawn "reboot")
         ]

