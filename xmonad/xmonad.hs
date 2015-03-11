import XMonad
import XMonad.Layout.NoBorders (noBorders)
import XMonad.Layout.Reflect
import XMonad.Layout.Fullscreen
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Actions.GridSelect
import XMonad.Actions.CycleWS
-- import XMonad.Actions.Navigation2D
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Config.Gnome
import qualified XMonad.StackSet as W

main = xmonad myConfig

myConfig = gnomeConfig { modMask = mod4Mask -- use the super key

-- , terminal = "gnome-terminal"

, layoutHook =
    noBorders $ -- remove borders
    avoidStruts $ -- dont cover gnome panel
    fullscreenFull $  -- but allow fullscreen windows to cover panel
    layoutHook gnomeConfig
    -- myLayout

, manageHook = composeAll [ manageHook gnomeConfig
                          -- float pidgin buddy list
                          , (className =? "Pidgin" <&&> title =? "Buddy List")  --> doFloat
                          -- necessary for fullscreen windows
                          , isFullscreen --> doFullFloat
                          ]

, handleEventHook = composeAll [ handleEventHook gnomeConfig
                               -- necessary for fullscreen windows
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
         , ("M-t", spawn "gnome-terminal")
         , ("M-c", spawn "pidgin")
         , ("M-v", spawn "/opt/cisco/anyconnect/bin/vpnui")
         , ("M-m", spawn "VirtualBox")
         , ("C-<Print>", spawn "gnome-screenshot -i")
         , ("M-x", kill)
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
         ]

myLayout = tiled ||| reflectHoriz tiled ||| Full
    where
        tiled = Tall nmaster delta ratio
        nmaster = 1
        ratio = 1/2
        delta = 3/100

onScreen d f = do mws <- screenWorkspace d
                  case mws of
                      Nothing -> return ()
                      Just ws -> windows (f ws)

