import XMonad
import XMonad.Layout.NoBorders (noBorders)
import XMonad.Layout.Reflect
import XMonad.Hooks.ManageDocks
import XMonad.Actions.GridSelect
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Config.Gnome

main = xmonad myConfig

myConfig = gnomeConfig { modMask = mod4Mask -- use the super key
                         , terminal = "gnome-terminal"

                         -- remove borders, uncover gnome-panel, custom layout
                         , layoutHook = noBorders $ avoidStruts $ myLayout

                         -- modded manage hook
                         , manageHook = myManageHook <+> manageHook gnomeConfig

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
         ]

myLayout = tiled ||| reflectHoriz tiled ||| Mirror tiled ||| Full
    where
        tiled = Tall nmaster delta ratio
        nmaster = 1
        ratio = 1/2
        delta = 3/100

myManageHook = composeAll [
                           (className =? "Pidgin" <&&> title =? "Buddy List")  --> doFloat
                          ]
