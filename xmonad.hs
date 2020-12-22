-- & FIX: Could not find module ‘XMonad...’
-- &   $ rm -rf .ghc/
-- &   $ sudo ghc-pkg recache


--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

import XMonad
import Data.Tree
import Data.Monoid
import System.Exit

import XMonad.Util.Run
import XMonad.Util.Paste
import XMonad.Util.SpawnOnce
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Spacing
import XMonad.Actions.Submap
import XMonad.Actions.KeyRemap
import XMonad.Actions.WindowBringer
import XMonad.Actions.UpdatePointer
import qualified Data.Map        as M
import qualified XMonad.StackSet as W
import qualified XMonad.Actions.TreeSelect as TS
import qualified XMonad.Actions.GridSelect as GS

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "alacritty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False  -- Default: True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["n1","t2","e3","w4","w5","w6","w7","w8","w9"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#282c34"
myFocusedBorderColor = "#46d9ff"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
emacsKeyRemap :: KeymapTable
emacsKeyRemap = KeymapTable [ ((controlMask, xK_b), (0, xK_Left))
                            , ((controlMask, xK_f), (0, xK_Right))
                            , ((mod1Mask, xK_b), (controlMask, xK_Left))
                            , ((mod1Mask, xK_f), (controlMask, xK_Right))
                            , ((controlMask, xK_p), (0, xK_Up))
                            , ((controlMask, xK_n), (0, xK_Down))
                            , ((controlMask, xK_a), (0, xK_Home))
                            , ((controlMask, xK_e), (0, xK_End))
                            , ((mod1Mask, xK_less), (controlMask, xK_Home))
                            , ((mod1Mask, xK_greater), (controlMask, xK_End))
                            , ((mod1Mask, xK_v), (0, xK_Prior))
                            , ((controlMask, xK_v), (0, xK_Next))
                            , ((controlMask, xK_d), (0, xK_Delete))
                            -- search
                            , ((controlMask, xK_s), (controlMask, xK_f))
                            -- copy/cut/paste
                            , ((controlMask, xK_w), (controlMask, xK_x))
                            , ((mod1Mask, xK_w), (controlMask, xK_c))
                            , ((controlMask, xK_y), (controlMask, xK_v))
                            -- undo/redo
                            , ((controlMask, xK_underscore), (controlMask, xK_z))
                            , ((mod1Mask, xK_underscore), (controlMask, xK_y))
                            ]

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- & [ Emulating keys -- Lost focus 
    -- ,((controlMask, xK_f), bindFirst [(className =? "Firefox" <||>
    --                                   className =? "Chromium"
    --                                   , sendKey 0 xK_Right),
    --                                   (pure True, sendKey controlMask xK_f)])
    -- ,((controlMask, xK_b), bindFirst [(className =? "Firefox" <||>
    --                                   className =? "Chromium"
    --                                   , sendKey 0 xK_Left),
    --                                   (pure True, sendKey controlMask xK_b)])
    -- ,((controlMask, xK_p), bindFirst [(className =? "Firefox" <||>
    --                                   className =? "Chromium"
    --                                   , sendKey 0 xK_Up),
    --                                   (pure True, sendKey controlMask xK_p)])
    -- ,((controlMask, xK_n), bindFirst [(className =? "Firefox" <||>
    --                                   className =? "Chromium"
    --                                   , sendKey 0 xK_Down),
    --                                   (pure True, sendKey controlMask xK_n)])
    -- & ]
    -- & [ Remap key bindings submap
    , ((modm,               xK_a), submap . M.fromList $
       [ ((0,               xK_e), setKeyRemap emacsKeyRemap)
       , ((0,               xK_x), setKeyRemap emptyKeyRemap)
       , ((0,               xK_s), spawn "swap-ralt-ctrl")
       ])
    , ((modm,               xK_s), do
          setKeyRemap emacsKeyRemap
          setKeyRemap emptyKeyRemap
      )
    -- & ]
    -- & [ Window menu with dmenu
    , ((modm, xK_d     ), gotoMenu)
    , ((modm .|. shiftMask, xK_d     ), bringMenu)
    -- & ]
    -- & [ Grid select
    , ((modm, xK_f     ), GS.goToSelected def)
    , ((modm, xK_i), GS.spawnSelected def myGridActions)
    -- & ]
    -- & [ GUI menus
    , ((modm, xK_u     ), TS.treeselectAction myTreeConfig myTreeActions)
    -- & ]

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "dmenu_run")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm, xK_ntilde), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    ++ buildKeyRemapBindings [emacsKeyRemap,emptyKeyRemap]


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
-- TreeSelect menu:

myTreeActions = [
  Node (TS.TSNode "+ Accessories" "Accessory applications" (return ()))
    [ Node (TS.TSNode "Archive Manager" "Tool for archived packages" (spawn "file-roller")) []
    , Node (TS.TSNode "Calculator" "Gui version of qalc" (spawn "qalculate-gtk")) []
    , Node (TS.TSNode "Picom Toggle on/off" "Compositor for window managers" (spawn "killall picom; picom --experimental-backend")) []
    , Node (TS.TSNode "Virt-Manager" "Virtual machine manager" (spawn "virt-manager")) []
    , Node (TS.TSNode "Virtualbox" "Oracle's virtualization program" (spawn "virtualbox")) []
    ]
  , Node (TS.TSNode "+ Graphics" "graphics programs" (return ()))
    [ Node (TS.TSNode "Gimp" "GNU image manipulation program" (spawn "gimp")) []
    , Node (TS.TSNode "Inkscape" "An SVG editing program" (spawn "inkscape")) []
    , Node (TS.TSNode "LibreOffice Draw" "LibreOffice drawing program" (spawn "lodraw")) []
    , Node (TS.TSNode "Shotwell" "Photo management program" (spawn "shotwell")) []
    ]
  , Node (TS.TSNode "+ Internet" "internet and web programs" (return ()))
    [ Node (TS.TSNode "Brave" "A privacy-oriented web browser" (spawn "brave")) []
    , Node (TS.TSNode "Discord" "Chat and video chat platform" (spawn "discord")) []
    , Node (TS.TSNode "Elfeed" "An Emacs RSS feed reader" (spawn "emacsclient -c -a '' --eval '(elfeed)'")) []
    , Node (TS.TSNode "Firefox" "Open source web browser" (spawn "firefox")) []
    , Node (TS.TSNode "Mastodon" "An Emacs mastodon client" (spawn "emacsclient -c -a '' --eval '(mastodon)'")) []
    , Node (TS.TSNode "Mu4e" "An Emacs email client" (spawn "emacsclient -c -a '' --eval '(mu4e)'")) []
    , Node (TS.TSNode "Nextcloud" "File syncing desktop utility" (spawn "nextcloud")) []
    , Node (TS.TSNode "Qutebrowser" "Minimal web browser" (spawn "qutebrowser")) []
    , Node (TS.TSNode "Surf Browser" "Suckless surf web browser" (spawn "surf")) []
    , Node (TS.TSNode "Thunderbird" "Open source email client" (spawn "thunderbird")) []
    , Node (TS.TSNode "Transmission" "Bittorrent client" (spawn "transmission-gtk")) []
    , Node (TS.TSNode "Zoom" "Web conferencing" (spawn "zoom")) []
    ]
  , Node (TS.TSNode "+ Multimedia" "sound and video applications" (return ()))
    [ Node (TS.TSNode "Alsa Mixer" "Alsa volume control utility" (spawn (myTerminal ++ " -e alsamixer"))) []
    , Node (TS.TSNode "Audacity" "Graphical audio editing program" (spawn "audacity")) []
    , Node (TS.TSNode "Deadbeef" "Lightweight music player" (spawn "deadbeef")) []
    , Node (TS.TSNode "EMMS" "Emacs multimedia player" (spawn "xxx")) []
    , Node (TS.TSNode "Kdenlive" "Open source non-linear video editor" (spawn "kdenlive")) []
    , Node (TS.TSNode "OBS Studio" "Open Broadcaster Software" (spawn "obs")) []
    , Node (TS.TSNode "Pianobar" "A terminal Pandora client" (spawn (myTerminal ++ " -e pianobar"))) []
    , Node (TS.TSNode "VLC" "Multimedia player and server" (spawn "vlc")) []
    ]
  , Node (TS.TSNode "+ Office" "office applications" (return ()))
    [ Node (TS.TSNode "LibreOffice" "Open source office suite" (spawn "libreoffice")) []
    , Node (TS.TSNode "LibreOffice Base" "Desktop database front end" (spawn "lobase")) []
    , Node (TS.TSNode "LibreOffice Calc" "Spreadsheet program" (spawn "localc")) []
    , Node (TS.TSNode "LibreOffice Draw" "Diagrams and sketches" (spawn "lodraw")) []
    , Node (TS.TSNode "LibreOffice Impress" "Presentation program" (spawn "loimpress")) []
    , Node (TS.TSNode "LibreOffice Math" "Formula editor" (spawn "lomath")) []
    , Node (TS.TSNode "LibreOffice Writer" "Word processor" (spawn "lowriter")) []
    , Node (TS.TSNode "Zathura" "PDF Viewer" (spawn "zathura")) []
    ]
  , Node (TS.TSNode "+ Programming" "programming and scripting tools" (return ()))
    [ Node (TS.TSNode "+ Emacs" "Emacs is more than a text editor" (return ()))
      [ Node (TS.TSNode "Emacs Client" "Doom Emacs launched as client" (spawn "emacsclient -c -a emacs")) []
      , Node (TS.TSNode "M-x dired" "File manager for Emacs" (spawn "emacsclient -c -a '' --eval '(dired nil)'")) []
      , Node (TS.TSNode "M-x elfeed" "RSS client for Emacs" (spawn "emacsclient -c -a '' --eval '(elfeed)'")) []
      , Node (TS.TSNode "M-x emms" "Emacs" (spawn "emacsclient -c -a '' --eval '(emms)' --eval '(emms-play-directory-tree \"~/Music/Non-Classical/70s-80s/\")'")) []
      , Node (TS.TSNode "M-x erc" "IRC client for Emacs" (spawn "emacsclient -c -a '' --eval '(erc)'")) []
      , Node (TS.TSNode "M-x eshell" "The Eshell in Emacs" (spawn "emacsclient -c -a '' --eval '(eshell)'")) []
      , Node (TS.TSNode "M-x ibuffer" "Emacs buffer list" (spawn "emacsclient -c -a '' --eval '(ibuffer)'")) []
      , Node (TS.TSNode "M-x mastodon" "Emacs" (spawn "emacsclient -c -a '' --eval '(mastodon)'")) []
      , Node (TS.TSNode "M-x mu4e" "Email client for Emacs" (spawn "emacsclient -c -a '' --eval '(mu4e)'")) []
      , Node (TS.TSNode "M-x vterm" "Emacs" (spawn "emacsclient -c -a '' --eval '(+vterm/here nil))'")) []
      ]
    , Node (TS.TSNode "Python" "Python interactive prompt" (spawn (myTerminal ++ " -e python"))) []
    ]
  , Node (TS.TSNode "+ System" "system tools and utilities" (return ()))
    [ Node (TS.TSNode "Alacritty" "GPU accelerated terminal" (spawn "alacritty")) []
    , Node (TS.TSNode "Dired" "File manager for Emacs" (spawn "emacsclient -c -a '' --eval '(dired nil)'")) []
    , Node (TS.TSNode "Eshell" "The eshell in Emacs" (spawn "emacsclient -c -a '' --eval '(eshell)'")) []
    , Node (TS.TSNode "Gufw" "GUI uncomplicated firewall" (spawn "gufw")) []
    , Node (TS.TSNode "Htop" "Terminal process viewer" (spawn (myTerminal ++ " -e htop"))) []
    , Node (TS.TSNode "LXAppearance" "Customize look and feel; set GTK theme" (spawn "lxappearance")) []
    , Node (TS.TSNode "Nitrogen" "Wallpaper viewer and setter" (spawn "nitrogen")) []
    , Node (TS.TSNode "PCManFM" "Lightweight graphical file manager" (spawn "pcmanfm")) []
    , Node (TS.TSNode "Qt5ct" "Change your Qt theme" (spawn "qt5ct")) []
    , Node (TS.TSNode "Simple Terminal" "Suckless simple terminal" (spawn "st")) []
    , Node (TS.TSNode "Stress Terminal UI" "Stress your system" (spawn (myTerminal ++ " -e s-tui"))) []
    ]
  , Node (TS.TSNode "+ Backgrounds" "Set background using feh" (return ()))
    [ Node (TS.TSNode "Random" "Set random background" (spawn "fehrand")) []
    , Node (TS.TSNode "Vi" "vi/vim graphical cheat sheet" (spawn "feh .xmonad/vi_keybindings.gif")) []
    , Node (TS.TSNode "XMonad" "xmonad default bindings" (spawn "feh .xmonad/xmonad_keybindings.png"))  []
    ]
  , Node (TS.TSNode "+ Brightness" "Sets screen brightness using xbacklight" (return ()))
    [ Node (TS.TSNode "Bright" "FULL POWER!!"            (spawn "xbacklight -set 100")) []
    , Node (TS.TSNode "Normal" "Normal Brightness (50%)" (spawn "xbacklight -set 50"))  []
    , Node (TS.TSNode "Dim"    "Quite dark"              (spawn "xbacklight -set 10"))  []
    ]
  , Node (TS.TSNode "+ XMonad Controls" "window manager commands" (return ()))
    [ Node (TS.TSNode "Recompile" "Recompile XMonad" (spawn "xmonad --recompile")) []
    , Node (TS.TSNode "Restart" "Restart XMonad" (spawn "xmonad --restart")) []
    , Node (TS.TSNode "Quit" "Restart XMonad" (io exitSuccess)) []
    , Node (TS.TSNode "Shutdown" "Poweroff the system" (spawn "systemctl poweroff")) []
    ]
  ]
myTreeConfig = TS.TSConfig { TS.ts_hidechildren = True
                           , TS.ts_background   = 0xdd282c34
                           , TS.ts_font         = "xft:Terminus:regular:size=10:antialias=true:hinting=true"
                           , TS.ts_node         = (0xffd0d0d0, 0xff1c1f24)
                           , TS.ts_nodealt      = (0xffd0d0d0, 0xff282c34)
                           , TS.ts_highlight    = (0xffffffff, 0xff755999)
                           , TS.ts_extra        = 0xffd0d0d0
                           , TS.ts_node_width   = 200
                           , TS.ts_node_height  = 16
                           , TS.ts_originX      = 100
                           , TS.ts_originY      = 100
                           , TS.ts_indent       = 80
                           , TS.ts_navigate     = myTreeNavigation
                           }
myTreeNavigation = M.fromList
    [ ((0, xK_Escape), TS.cancel)
    , ((0, xK_Return), TS.select)
    , ((0, xK_space),  TS.select)
    , ((0, xK_Up),     TS.movePrev)
    , ((0, xK_Down),   TS.moveNext)
    , ((0, xK_Left),   TS.moveParent)
    , ((0, xK_Right),  TS.moveChild)
    , ((0, xK_k),      TS.movePrev)
    , ((0, xK_j),      TS.moveNext)
    , ((0, xK_h),      TS.moveParent)
    , ((0, xK_l),      TS.moveChild)
    , ((0, xK_o),      TS.moveHistBack)
    , ((0, xK_i),      TS.moveHistForward)
    , ((0, xK_b), TS.moveTo ["+ Backgrounds", "Random"])
    ]

------------------------------------------------------------------------
-- Layouts:
myGridActions = [ "audacity"
                 , "deadbeef"
                 , "emacsclient -c -a \"\""
                 , "firefox"
                 , "gimp"
                 , "pcmanfm"
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
myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = spacingRaw  True (Border 0 5 5 5) True (Border 5 5 5 5) True $ Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
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
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    -- , className =? "Emacs"          -->
    --   (ask >>= \w -> liftX (setKeyRemap emacsKeyRemap) >> idHook)
    ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = (gets (W.peek . windowset) >>= maybeEmacsRemap) >> updatePointer (0.5, 0.5) (0, 0)

maybeEmacsRemap :: Maybe Window -> X ()
maybeEmacsRemap = maybe (return ()) emacsRemap

emacsRemap :: Window -> X ()
emacsRemap w = fmap (`elem` ["Emacs", "Alacritty"]) name >>= \b -> if b
    then setKeyRemap emptyKeyRemap
    else setKeyRemap emacsKeyRemap
    where name = withDisplay $ \d -> fmap resClass $ io $ getClassHint d w

-- className = ask >>= (\w -> liftX $ withDisplay $ \d -> fmap resClass $ io $ getClassHint d w)
-- q =? x = fmap (== x) q
-- p --> f = p >>= \b -> if b then f else return mempty
------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
--   myStartupHook = return ()
-- Bad practice.
--   myStartupHook = do
--     spawnOnce "xrandr-monitors &"
--     spawnOnce "compton &"
--     spawnOnce "swap-ralt-ctrl &"
--     spawnOnce "nm-applet &"
--     spawnOnce "volumeicon &"
--     spawnOnce "fehrand &"
myStartupHook = do
  setDefaultKeyRemap emacsKeyRemap [emacsKeyRemap, emptyKeyRemap]


------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
    barPipe <- spawnPipe "xmobar -x 0 ~/.xmonad/xmobar.config"
    xmonad $ docks $ def {
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
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook >>
          dynamicLogWithPP xmobarPP {
            ppOutput = \x -> hPutStrLn barPipe x
            , ppOrder = \(ws:l:t:ex) -> [ws,l]++ex
            },
        startupHook        = myStartupHook
    }

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
