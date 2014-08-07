-- default desktop configuration for Fedora

import System.Posix.Env (getEnv)
import Data.Maybe (maybe)

import XMonad
import XMonad.Config.Desktop
import XMonad.Config.Gnome
import XMonad.Config.Kde
import XMonad.Config.Xfce
import XMonad.Actions.GridSelect
import XMonad.Util.EZConfig

main = do
     session <- getEnv "DESKTOP_SESSION"
     xmonad  $ (maybe desktopConfig desktop session)
         { modMask = mod4Mask
         }
         `additionalKeysP` myKeys
    
myKeys = [
    ("M-g", goToSelected defaultGSConfig)
    , ("M-S-l", spawn "gnome-screensaver-command -l")
    , ("M-o", spawn "dmenu_run")
    , ("M-S-o", spawn "gmrun")
    ]


desktop "gnome" = gnomeConfig
desktop "kde" = kde4Config
desktop "xfce" = xfceConfig
desktop "xmonad-gnome" = gnomeConfig
desktop _ = desktopConfig
