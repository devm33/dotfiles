import XMonad
import XMonad.Layout.NoBorders (noBorders)
import XMonad.Hooks.ManageDocks
import XMonad.Actions.GridSelect
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Config.Gnome

main = xmonad myConfig

myConfig = gnomeConfig { modMask = mod4Mask -- use the super key
                         , terminal = "gnome-terminal"

                         -- remove all borders, dont cover gnome-panel 
                         , layoutHook = noBorders $ avoidStruts $ layoutHook defaultConfig
                         -- dont tile gnome-panel
                         , manageHook = manageDocks
                         } `additionalKeysP` myKeys

myKeys = [ ("M-g", goToSelected defaultGSConfig)
         , ("M-l", spawn "gnome-screensaver-command -l")
         , ("M-o", spawn "dmenu_run")
         , ("M-S-o", spawn "gmrun")
         , ("M-b", spawn "google-chrome")
         , ("M-f", spawn "firefox")
         , ("M-c", spawn "pidgin")
         , ("M-x", kill)
         , ("M-v", spawn "/opt/cisco/anyconnect/bin/vpnui")
         ]

