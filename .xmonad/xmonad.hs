import XMonad
import Data.Monoid
import System.Exit

import XMonad.Actions.CycleWS

import XMonad.Hooks.SetWMName
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog

import XMonad.Layout.PerWorkspace
import XMonad.Layout.Renamed
import XMonad.Layout.Spacing

import XMonad.ManageHook

import XMonad.Operations

import XMonad.Util.SpawnOnce -- used in autostart
import XMonad.Util.Run
import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal      = "kitty"
myAppRunner     = "rofi -show drun"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myClickJustFocuses :: Bool
myClickJustFocuses = False

myBorderWidth   = 3
myNormalBorderColor  = "#282a36"
myFocusedBorderColor = "#6272a4"

myModMask       = mod4Mask

-- A tagging example:
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
myWorkspaces    = ["HQ  ","WWW ","DEV1","DEV2","GFX ","VID ","7","8","-"]

-- NamedScratchpads
x :: Rational -- of screen width from the left
x = 0.005
y :: Rational -- of screen height from the top
y = 0.025
w :: Rational -- of screen width
w = 0.99
h :: Rational -- of screen height
h = 0.95

myKeys :: [(String, X ())]
myKeys =
    [       ("M-S-q"                        , io(exitWith ExitSuccess))
        ,   ("M-S-r"                        , spawn "xmonad --recompile; killall xmobar; xmonad --restart")
        ,   ("M-M1-l"                       , spawn "betterlockscreen -l")
        ,   ("M-S-w"                        , kill)
        ,   ("M-M1-r"                       , refresh)
    -- Applications
        ,   ("M-r"                          , spawn myAppRunner)
        ,   ("M-<Return>"                   , spawn myTerminal)
    -- Workspaces
        ,   ("M-<L>"                        , prevWS)
        ,   ("M-<R>"                        , nextWS)
    -- Layout
        ,   ("M-j"                          , windows W.focusDown)
        ,   ("M-k"                          , windows W.focusUp)
        ,   ("M-S-j"                        , windows W.swapDown)
        ,   ("M-S-k"                        , windows W.swapUp)
        ,   ("M-m"                          , windows W.focusMaster)
        ,   ("M-S-m"                        , windows W.swapMaster)
        ,   ("M-h"                          , sendMessage Shrink)
        ,   ("M-l"                          , sendMessage Expand)
        ,   ("M-<Tab>"                      , sendMessage NextLayout)
        ,   ("M-s"                          , withFocused $ windows . W.sink)
        ,   ("M-f"                          , sendMessage ToggleStruts)
        ,   ("M+<KP_Subtract>"              , sendMessage (IncMasterN (-1)))
        ,   ("M+<KP_Add>"                   , sendMessage (IncMasterN 1))
    -- Volume
        ,   ("<XF86AudioMute>"              , spawn "amixer set Master toggle")
        ,   ("<XF86AudioLowerVolume>"       , spawn "amixer set Master 5%-")
        ,   ("<XF86AudioRaiseVolume>"       , spawn "amixer set Master 5%+")
        ,   ("M-<XF86AudioLowerVolume>"     , spawn "amixer set Master 1%-")
        ,   ("M-<XF86AudioRaiseVolume>"     , spawn "amixer set Master 1%+")
    -- Brightness
        ,   ("<XF86MonBrightnessUp>"        , spawn "xbacklight +5")
        ,   ("<XF86MonBrightnessDown>"      , spawn "xbacklight -5")
    -- Media Controls
        ,   ("M-<Space>"                    , spawn "playerctl play-pause")
        ,   ("M-S-<L>"                      , spawn "playerctl previous")
        ,   ("M-S-<R>"                      , spawn "playerctl next")
        ,   ("<XF86AudioPlay>"              , spawn "playerctl play-pause")
        ,   ("<XF86AudioStop>"              , spawn "playerctl play-pause")
        ,   ("<XF86AudioPrev>"              , spawn "playerctl previous")
        ,   ("<XF86AudioNext>"              , spawn "playerctl next")
    -- Apps
        ,   ("M-a t"                        , namedScratchpadAction myScratchpads "terminal")
        ,   ("M-a r"                        , spawn "rofi -show run")
        ,   ("M-a s"                        , namedScratchpadAction myScratchpads "spt")
        ,   ("M-a e"                        , namedScratchpadAction myScratchpads "emacs")
        ,   ("M-a p"                        , namedScratchpadAction myScratchpads "pass")
        ,   ("M-a n"                        , namedScratchpadAction myScratchpads "nm")
        ,   ("M-a a"                        , namedScratchpadAction myScratchpads "agenda")
        ,   ("M-a m"                        , namedScratchpadAction myScratchpads "mail")
    ]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayoutHook = avoidStruts $ spacing 4
  $     onWorkspace "HQ  "              (graveyard ||| Full)
  $     onWorkspace "WWW "              (columns ||| graveyard ||| Full)
  $     onWorkspace "DEV1"              Full
  $     onWorkspace "DEV2"              (columns ||| Full)
  $     onWorkspace "GFX "              Full
  $     onWorkspace "VID "              (Full ||| columns)
  $     onWorkspace "-"                 columns
  $     columns ||| graveyard ||| Full
  where
    columns = Tall nmaster delta ratio
    graveyard = Mirror columns

-- The default number of windows in the master pane
    nmaster = 1
    doubleMaster = 2

-- Default proportion of screen occupied by master pane
    ratio   = 1/2
    doubleMasterRatio = 3/4

-- Percent of screen to increment by when resizing panes
    delta   = 3/100

myScratchpads :: [NamedScratchpad]
myScratchpads =
  [
        terminalPad
    ,   sptPad
    ,   passPad
    ,   nmPad
    ,   mailPad
    ,   emacsPad
  ]

terminalPad :: NamedScratchpad
terminalPad = NS "terminal"   spawnTerm findTerm manageTerm
  where
    spawnTerm = "kitty -T SPterminal"
    findTerm = title =? "SPterminal"
    manageTerm = customFloating $ W.RationalRect x y w h

sptPad :: NamedScratchpad
sptPad = NS "spt" spawnSpt findSpt manageSpt
  where
    spawnSpt = "fish ~/.bin/spotify.fish"
    findSpt = title =? "SPspt"
    manageSpt = customFloating $ W.RationalRect x y w h

passPad :: NamedScratchpad
passPad = NS "pass" spawnPass findPass managePass
  where
    spawnPass = "keepassxc &"
    findPass = className =? "KeePassXC"
    managePass = customFloating $ W.RationalRect x y w h

nmPad :: NamedScratchpad
nmPad = NS "nm" spawnNM findNM manageNM
  where
    spawnNM = "kitty -T \"SPnm\" -e nmtui-connect &"
    findNM = title =? "SPnm"
    manageNM = customFloating $ W.RationalRect x y w h

mailPad :: NamedScratchpad
mailPad = NS "mail" spawnMail findMail manageMail
  where
    spawnMail = "thunderbird &"
    findMail = className =? "Thunderbird"
    manageMail = customFloating $ W.RationalRect  x y w h

emacsPad :: NamedScratchpad
emacsPad = NS "emacs" spawnEmacs findEmacs manageEmacs
  where
    spawnEmacs = "emacsclient -c --frame-parameters='(quote (name . \"SPEmacs\"))'"
    findEmacs = title =? "SPEmacs"
    manageEmacs = customFloating $ W.RationalRect x y w h

-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
  [
    -- Floating
        className =? "confirm"          --> doFloat
  ,     className =? "file_progress"    --> doFloat
  ,     className =? "dialog"           --> doFloat
  ,     className =? "download"         --> doFloat
  ,     className =? "error"            --> doFloat
  ,     className =? "notification"     --> doFloat
  ,     className =? "Unity"            --> doFloat
  ,     className =? "JetBrains Toolbox"--> doFloat
  ,     className =? "jetbrains-toolbox"--> doFloat
  ,     className =? "Gimp-2.10"             --> doFloat
  -- Shifts
  ,     title =? "htop"             --> doShift("HQ  ")
  ,     title =? "ranger"              --> doShift("HQ  ")
  ,     className =? "obs"              --> doShift("HQ  ")
  ,     className =? "firefox"          --> doShift("WWW ")
  ,     className =? "Unity"            --> doShift("DEV1")
  ,     className =? "UnityHub"         --> doShift("DEV1")
  ,     className =? "Calibre"          --> doShift("DEV1")
  ,     className =? "jetbrains-rider"  --> doShift("DEV2")
  ,     className =? "Blender"          --> doShift("GFX ")
  ,     className =? "Gimp"             --> doShift("GFX ")
  -- ,     className =? "myMediaPlayer"    --> doShift(myWorkspaces || 6)
  ]

-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook xmobar = dynamicLogWithPP $ defaultPP
    {
    --how to print the tag of the currently focused workspace
      ppCurrent = xmobarColor "#ebdbb2" "" . wrap "" ""
    , ppVisible = xmobarColor "#6272a4" "" . wrap "" ""
    --how to print tags of invisible workspaces which contain windows
    , ppHidden          = xmobarColor "#44475a" "" . wrap "" ""
    --how to print tags of empty invisible workspaces
    , ppHiddenNoWindows = xmobarColor "#282a36" ""
    --format to be applied to tags of urgent workspaces
    , ppUrgent          = xmobarColor "#ffb86c" ""
    --separator to use between different log sections
    , ppSep             = "<fc=#665c54> | </fc>"
    -- separator to use between workspace tags
    , ppWsSep           =  " "
    --window title format
    , ppTitle           = xmobarColor "#665c54" "" . shorten 32
    --layout name format
    , ppLayout          = xmobarColor "#00ff00" ""
    --how to order the different log sections
    , ppOrder           = \(ws:t:ex) -> [ws]
    --, ppExtras =

    , ppOutput = \x -> hPutStrLn xmobar x
    }

-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  spawnOnce "nitrogen --restore &"
  spawnOnce "picom &"
  spawnOnce "kitty -T \"htop\" -e htop &"
  spawnOnce "kitty -T \"ranger\" -e ranger &"
  spawnOnce "fish ~/.bin/init.sh"
  spawnOnce "emacs --daemon &"
  setWMName "XMonad"

-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
  xmobar0 <- spawnPipe "xmobar -x 0 ~/.config/xmobar/xmobarrc"
  xmonad $ docks defaults{
                        logHook = myLogHook xmobar0
                 }

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
--        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayoutHook,
        manageHook         = myManageHook <+> namedScratchpadManageHook myScratchpads,
        handleEventHook    = myEventHook,
        --logHook            = myLogHook,
        startupHook        = myStartupHook
    }`additionalKeysP` myKeys

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
