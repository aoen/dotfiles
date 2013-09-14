{-# LANGUAGE DeriveDataTypeable, NoMonomorphismRestriction, TypeSynonymInstances, MultiParamTypeClasses #-}

import System.Posix.Unistd
import System.FilePath.Posix (takeFileName)
import System.Posix.Types (ProcessID)
import System.Random
import Codec.Binary.UTF8.String (encodeString)
import System.Posix.Process (executeFile)
import Text.Printf
import Prelude hiding (catch)
import Control.Exception
import Control.Monad
import Data.List
import Data.Monoid
import Data.Maybe
import qualified Data.Map as M
import Graphics.X11.ExtraTypes.XF86

import XMonad

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ToggleHook
import XMonad.Hooks.UrgencyHook

import XMonad.Layout.Decoration
import XMonad.Layout.Gaps
import XMonad.Layout.GridVariants
import XMonad.Layout.IM
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ToggleLayouts
import qualified XMonad.Layout.Grid as G

import XMonad.Actions.CycleWS hiding (moveTo)
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.GroupNavigation
import XMonad.Actions.PhysicalScreens
import XMonad.Actions.Search
import XMonad.Actions.TopicSpace
import XMonad.Actions.UpdatePointer
import XMonad.Actions.WindowGo
import XMonad.Actions.WindowBringer

import XMonad.Util.Cursor
import XMonad.Util.Paste
import XMonad.Util.EZConfig
import XMonad.Util.Run
import XMonad.Util.Scratchpad
import XMonad.Util.WorkspaceCompare ( getSortByIndex )
import XMonad.Util.Dmenu

import qualified XMonad.Prompt as Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.Shell
import qualified XMonad.Prompt.Window as PWin

import qualified XMonad.StackSet as W

import MySpawnOn

------------------TYPES-------------------
xclipToXsel :: X ()
scriptKeys :: (String, [(String, X () )])
addMetaKey :: String -> [(String, a)] -> [(String,a)]
termHold :: String -> X()
termExec :: String -> X()
namedTermExec :: String -> String -> X()
runTermAtDir :: String -> X()
addManyMetaKeys :: [(String, [(String, a)])] -> [(String, a)]
isNotInfixOf :: (Eq a) => [a] -> [a] -> Bool
swapBottom :: W.StackSet i l a s sd -> W.StackSet i l a s sd
ifFocIs :: XMonad.Query Bool -> X () -> X () -> X ()
apply2nd :: (b->c) -> (a,b) -> (a,c)
apply1st :: (a->c) -> (a,b) -> (c,b)
map2 :: (b->c) -> [(a,b)] -> [(a,c)]
map1 :: (a->c) -> [(a,b)] -> [(c,b)]

-------------------HOTKEYS-------------------
-- Search enines, there are two search:
-- prompt: brings up a prompt to enter the search string
--   e.g. <F1>g
--        foo<enter>
--   will search "foo" on google
-- auto: uses the clipboard in some manner, and uses the "I feel lucky feature" of sites
--   e.g. <F2>y
--   assuming the clipboard contains "Foo Fighters" will use youtube's I'm feeling lucky feature to
--   play the first youtube song matching "Foo Fighters".

-- Generic Search Engines
webSearchMap = M.fromList [
  -- ("wolfram"  , alpha),
  ("dict"     , dictionary),
  ("email"    , searchEngine "Email"  "https://mail.google.com/mail/u/0/?shva=1#search/"),
  ("images"   , searchEngine "Images" "http://images.google.com/images?q="),
  ("github"   , searchEngine "GitHub" "https://github.com/search?q="),
  ("imdb"     , imdb),
  ("isohunt"  , isohunt),
  -- Directions to a certain address
  ("mapto"    , searchEngine  "Maps (Directions To)" (printf "%s%s+to+" mapPrefixStr altaddr)),
  -- Directions to a nearby on-concrete location (e.g. Subway Restaurant)
  ("mapnear"  , searchEngineF "Maps (Find Near)" (\s -> printf
                                                          "%s%s+to+%s+near+%s" 
                                                          mapPrefixStr altaddr (escape s) altaddr)),
  ("pirate"   , searchEngine  "Pirate Bay" "http://thepiratebay.sx/search/"),
  ("wiki"     , wikipedia)
  ]
  where mapPrefixStr = "http://maps.google.com/maps?q="
        addr         = "123+SOME+STREET"
        altaddr      = "124+SOME+STREET"

promptWebSearchMap = fmap webSearch $ M.union webSearchMap (M.fromList [
  ("youtube", youtube),
  ("lastfm" , searchEngine "LastFM" "http://www.last.fm/search?&autocorrect=1&type=artist&q="),
  ("groove" , searchEngine "Grooveshark" "http://grooveshark.com/#/search/songs/?query=")
  ])

autoWebSearchMap = fmap autoWebSearch $ M.union webSearchMap (M.fromList [
  ("youtube", searchEngine "Youtube" "http://www.google.com/search?btnI=I'm+Feeling+Lucky&ie=UTF-8&oe=UTF-8&q=site:youtube.com%20"),
  ("lastfm" , searchEngineF "LastFM" $ printf "http://www.last.fm/music/%s/+charts?rangetype=week&subtype=tracks" . escape),
  ("groove" , searchEngine "Grooveshark" "http://grooveshark.com/#/search/songs/?query=")
  ])

promptSearchMap = M.union promptWebSearchMap $ M.fromList [
  ("calculator", prompt2 "Calc" ?+ termHold . printf "calc '%s'"), -- Quick Calculator
  ("music"     , promptedTermExec "Music" "findSong") -- Find and play locals or songs by artist
  ]

autoSearchMap = M.union autoWebSearchMap $ M.fromList [
  ]

-------------------HOTKEYS-------------------
-- Get the entry that needs to be typed for each search engine from the
-- mappings of entries -> actions
promptSearchKeys = M.keys promptSearchMap
autoSearchKeys = M.keys autoSearchMap

-- Windows key + some keys = run/raise applications
appKeys = (
  "M", [
  (","  , hookNext "!viewChrome" False >>
          ifWindow isMainBrowser idHook spawnBrowser >> -- Spawn browser if it doesn't exist
          runOrRaiseWebsite "http://cloud.feedly.com/#latest" isRSSReader), -- Run or raise RSS reader
  -- Run the last downloaded file (because of my other scripts this works nicely with lots of file
  -- types, like .txt and .zip files)
  ("a"  , spawn' "openNewestDL"),
  ("b"  , runOrRaiseNext' "qbittorrent" "Qbittorrent"),
  ("c"  , raiseOrSpawnBrowser),
  ("S-c", spawnChrome),
  ("d"  , openURL "http://www.reddit.com"),
  ("e"  , runOrRaiseWebsite "https://calendar.google.com/" (isIconSuffix "Google Calendar")),
  ("f"  , runOrRaiseNext' "firefox" "Firefox"),
  ("S-f", spawn' "firefox"),
  ("g"  , runOrRaiseWebsite "https://mail.google.com/mail/u/0" (appName =? "mail.google.com__mail_u_0")),
  ("h"  , runOrRaiseTermApp "htop --sort-key PERCENT_CPU"),
  ("i"  , runOrRaiseNext' "eclipse" "Eclipse"),
  ("j"  , runOrRaiseNext' "hon" "Heroes of Newerth"),
  ("k"  , raise isAHK), -- Raise autokey config if it exists, otherwise issue hotkey to start it
  ("m"  , runOrRaiseTermApp "mutt"),
  ("n"  , runOrRaiseNext' "pwdNautilus" "Nautilus"),
  -- Opens the last accessed folder in a terminal in nautilus (requires the zsh plugin
  -- last-working-dir)
  ("S-n", runOrRaiseNext' (printf "gksudo \"dbus-launch nautilus --no-desktop --browser `cat %s/.zsh/cache/last-working-dir\"`" homeDir) "Nautilus"),
  ("o"  , spawn' "anon"),
  ("p"  , runOrRaiseNext' "gimp" "Gimp"),
  ("s"  , spawn' "skype"), -- Don't need to "run or raise next" this, because skype does that for us
  -- Switch between open terminals, or open a new one if none exists
  ("t"  , rrf term (className =? termWinClass <&&> title !~? scrapPrefixStr)),
  ("v"  , runOrRaiseNext' "playNewestTorrent" "Vlc"),
  ("S-v", runOrRaiseNext' "playSecondNewestTorrent" "Vlc"),
  ("w"  , runOrRaiseNext' "libreoffice" "LibreOffice"),
  -- TODO The "view' fullWS" should be replaced by a manage hook, but unfortunately I couldn't find
  -- a way to distinguish a chrome window from an incognito chrome window
  ("x"  , view' fullWS >> runOrRaiseNext' "chromium-browser --incognito" incogBrowserClass),
  ("y"  , runOrRaiseNext' "pidgin" "Pidgin"),
  ("z"  , spawn' term), -- Create new terminal
  -- Create new terminal at same location at the last opened directory
  ("S-z", runTermAtDir $ "cat " ++ homeDir ++ ".last_dir")
  ])

-- Alt key + some keys = perform a window manager function
xmonadKeys = (
   "M1"    , [
   ("a"    , focusUrgent), -- Focuses a workspace with an urgent message
   ("b"    , bringAllWindows) , -- Brings all windows to current term
   ("d"    , removeEmptyWorkspace), -- Removes unused workspaces
   ("f"    , sendMessage ToggleStruts), -- Toggle top/bot status bars
   ("h"    , viewScreen 0), -- Prev screen
   ("S-h"  , sendToScreen 0 >> viewScreen 0), -- Move to first monitor and focus
   ("k"    , windows W.focusUp >> initializeCurTopic), -- Next WS
   ("S-k"  , windows W.swapUp), -- Shift window up
   ("j"    , windows W.focusDown >> initializeCurTopic), -- Prev window
   ("S-j"  , windows W.swapDown), -- Shift window down
   ("l"    , viewScreen 1), -- Next screen
   ("S-l"  , sendToScreen 1 >> viewScreen 1), -- Move to second monitor and focus
   ("m"    , nextWS), -- Next workspace
   ("S-m"  , shiftToNext'), -- Shift window to next workspace
   ("n"    , prevWS), -- Previous workspace
   ("S-n"  , shiftToPrev'), -- Shift window to previous workspace
   ("p"    , toggleWS), -- Go to the last viewed WS
   ("<Tab>", toggleWS), -- Go to the last viewed WS
   ("q"    , quitHandler), -- Safe quit active window
   -- Hard quit active window (e.g. will quit vim even with unsaved changes) OR Close process that a
   -- clicked-on window belongs to
   ("S-q"  , altQuitHandler),
   ("s"    , withFocused $ windows . W.sink), -- Sink All
   ("t"    , sendMessage $ XMonad.Layout.MultiToggle.Toggle TABBED), -- Toggle between layouts
   ("u"    , swapNextScreen >> nextScreen), -- Cycle monitors (keep focus on same WS)
   ("v"    , sendMessage ToggleLayout), -- Cycle layouts
   ("w"    , newTermWS), -- Creates a new terminal workspace
   ("x"    , termExec "xprop | $PAGER"), -- Gets info about an window
   ("y"    , swapNextScreen), -- Cycle monitors (swap focus to other WS)
   ("0"    , toggleMute),
   ("-"    , lowerVol),
   ("="    , raiseVol),
   ("["    , sendMessage Shrink), -- Grow right windows
   ("S-["  , sendMessage MirrorShrink), -- Grow top windows
   ("]"    , sendMessage Expand), -- Grow left windows
   ("S-]"  , sendMessage MirrorExpand) -- Grow bottom windows
   ] ++
   -- alt+X/alt+shift+X swapto/moveto current window to workspace X
   [(key, func) |
       i           <- [1..length wses],
       let key     = show i,
       let ws      = wses !! (i-1),
       (func, key) <- [(view'  ws, key),
                       (moveTo ws, "S-" ++ key)]]
  )

-- Caps lock key (needs to be remapped to M3 in xmodmap) + some keys = run some kind of script
scriptKeys = (
   "M3", [
    -- Prepends to text files
   ("a"  , promptWithCompl "Add to File" promptConfig2 prependComplKeys ?+
               (\fileKey -> prependLinePrompt (prependComplMap M.! fileKey))),
   ("b"  , termHold "dlMusic"),
   ("c"  , spawn' "/opt/google/chrome/google-chrome --app=\"https://mail.google.com/mail?ui=2&view=cm&fs=1&tf=1\""), -- Send complex email
   ("d"  , spawn' "openNewestDL"), -- Opens the latest file in the chrome downloads folder
   ("e"  , promptedSpawn "Email" "sendRegEmail"), -- Send regular email to self
   ("h"  , spawn' "gksudo pm-suspend"), -- Sleep
   -- ("j"  , prompt2 "Jump To" ?+ runTermAtDir . printf "$(fasd -d -1 %s)"), -- Fuzzyjump to directory
   ("l"  , spawn' "sleep 0.5; xset dpms force off"), -- Turn off display
   ("m"  , termExec "alsamixer -V capture"), -- Adjust microphone levels
   ("S-m", termExec "~/bin/misc/record"), -- Adjust microphone levels
   -- Opening/Prepending to Text Files
   ("o"  , promptWithCompl "Open File" promptConfig2 fileKeys ?+
               (\fileKey -> runOrBringVim (fileMap M.! fileKey))),
   -- Opening/Prepending to Text Files
   ("S-o", swapToTermWS >> (promptWithCompl "Open File" promptConfig2 fileKeys ?+
               (\fileKey -> runOrRaiseVim (fileMap M.! fileKey)))),
   ("p"  , termExec "pingtest" ), -- Check internet connection
   -- Opening/Prepending to Text Files
   ("r"  , confirm "Restart?"  $ spawn' "/sbin/shutdown -r now"), -- Restart
   ("s"  , confirm "Shutdown?" $ spawn' "/sbin/shutdown now"), -- Shutdown
   ("t"  , raiseAndDoOrSpawnBrowser $ \win -> sendKeyWindow controlMask xK_t win), -- New Browser Tab
   -- New Browser Tab with clipboard contents
   ("S-t", raiseAndDoOrSpawnBrowser $ \win -> sendKeyWindow controlMask xK_t win >> pasteSelection'),
   ("u"  , {-swapToTermWS >>-} termHold "quickupdate"), -- Update packages
   ("S-u", {-swapToTermWS >>-} termHold "setup"), -- Make sure everything is consistent (run setup script)
   ("v"  , swapToTermWS >> termExec "vifm ~/videos/unwatched"), -- Open unwatched videos for selection
   ("w"  , runOrRaiseNext' "wicd-client -n" "Wicd-client.py"), -- Open network settings
   -- ("`"  , spawn' "soundSwitch"), -- Switch between headphones and speakers
   ("`"  , promptedTermHold "Timer" "timerMinutes"), -- Timer
   ("<KP_Add>"      , spawn' "likeskip --add"), -- Like then skip and add to dlist
   ("S-<KP_Add>"    , spawn' "likeskip --addmaybe"), -- Like then skip and add to maybe music
   ("<KP_Divide>"   , spawn' "playRecent"), -- Play recently dl'd local music
   ("<KP_Multiply>" , spawn' "playAll"), -- Play all music
   ("<KP_End>"      , spawn' "stationSwap"), -- Station Swap
   ("<KP_Home>"     , spawn' "pianoFull"), -- Pause (and possible start up)
   ("<KP_Left>"     , spawn' "stopMusic"), -- Stop all music
   ("<KP_Page_Up>"  , spawn' "togglePause"), -- Pause/Unpause (start music player if unpausing and none is started)
   ("<KP_Right>"    , spawn' "nextSong"),
   ("<KP_Down>"     , termExec "dislikeSong"),  -- Dislike
   ("<KP_Up>"       , spawn' "likeSong"), -- Like
   ("<Print>"       , spawn' "uploadImage") -- Upload a selected screen area to imgur
   ]
   -- Modifier+X Starts an X-minute timer
   ++ [(show i, termExec $ printf "timerMinutes %s" $ show i) | i <- [0..9]]
   -- ++ [(show i, spawn $ printf "mpd-rate %s" $ show i) | i <- [0..9]] -- Rate playing songs with Alt + 1-9
   )
   where
      -- Map of shortcut strings to files on disk, used for commands like opening and prepending to
      -- TODO should really use a trie here
      fileMap = M.fromList $
        fmap (\(x  , y) -> (printf "%s (%s)" x (takeFileName y)      , y)) [
          ("a"     , "~/.aliases.zsh")                               ,
          ("ba"    , "~/documents/lists/bandsandalbums.txt")         ,
          ("boo"   , "~/documents/lists/booksToRead.txt")            ,
          ("bot"   , "~/bin/auto/xmonad/botstatbar")                 ,
          ("bu"    , "~/documents/lists/toBuy.txt")                  ,
          ("ce"    , "/media/cell/.jota/shared.txt")                 ,
          ("cod"   , "~/documents/lists/codeits.txt")                ,
          ("com"   , "~/bin/auto/xmonad/commonbarsettings")          ,
          ("conf"  , "~/bin/resources/configs.txt")                  ,
          ("conr"  , "~/.conkyrrc")                                  ,
          ("conr"  , "~/.conkyrrc")                                  ,
          ("cont"  , "~/documents/lists/contactInfo.txt")                                  ,
          ("cou"   , "~/documents/lists/futureCourses.txt")          ,
          ("cro"   , "~/Dropbox/ubuntu/var/spool/cron/crontabs/dan") ,
          ("cru"   , "~/bin/resources/crud.txt")                     ,
          ("cu"    , "~/.custom.zsh")                                ,
          ("deb"   , "~/documents/lists/debts.txt")                  ,
          ("def"   , "~/.local/share/applications/defaults.list")    ,
          ("er"    , "~/.errors.log")                                ,
          ("en"    , "~/.zshenv")                                    ,
          ("f"     , "~/Dropbox/ubuntu/helper/fstab")                ,
          ("ga"    , "~/documents/lists/gamesToTry.txt")             ,
          ("gi"    , "~/documents/lists/giftIdeas.txt")              ,
          ("h"     , "~/documents/lists/hardtofindmusic.txt")        ,
          ("j"     , "~/documents/fun/jokes.txt")                    ,
          ("l"     , "~/documents/logs/kat.txt")                     ,
          ("ma"    , "~/documents/lists/maybemusic.txt")             ,
          ("mo"    , "~/documents/lists/movies.txt")                 ,
          ("mt"    , "~/documents/lists/mtgWishlist.txt")            ,
          ("mu"    , "~/documents/lists/music.txt")                  ,
          ("p"     , "~/bin/resources/packages.txt")                 ,
          ("sa"    , "~/documents/sasha2.txt")                       ,
          ("sc"    , "/tmp/scrapfile")                               ,
          ("se1"   , "~/bin/system/setup")                           ,
          ("se2"   , "~/bin/system/packages")                        ,
          ("so"    , "/etc/apt/sources.list")                        ,
          ("r"     , "~/documents/fun/riddles.txt")                  ,
          ("tod"   , "~/documents/todo/temp.txt")                    ,
          ("top"   , "~/bin/auto/xmonad/topstatbar")                 ,
          ("tor"   , "/etc/tor/torrc")                               ,
          ("vi"    , "~/.vimrc")                                     ,
          ("vo"    , "~/documents/lists/vocabTemp.txt")              ,
          ("w"     , "~/documents/logs/workoutLog.txt")              ,
          ("xi"    , "~/.xinitrc")                                   ,
          ("xmod"  , "~/.xmodmap")                                   ,
          ("xmon"  , "~/.xmonad/xmonad.hs")                          ,
          ("xr"    , "~/.Xresources")                                ,
          ("z"     , "~/.zshrc")
        ]
      fileKeys = M.keys fileMap
      -- Used to generate list of files that are prependable (for the addline script), only files in
      -- the documents folder are prependable
      prependComplMap = M.filter ( "~/documents" `isInfixOf` ) fileMap
      prependComplKeys = M.keys prependComplMap
      -- TODO make promptedSpawn handle multiple arguments and then convert this to use it
      prependLinePrompt file = prompt2 "Text to Add" ?+ spawnHere' . printf "prepend %s '%s'" file

-- Hotkeys that don't require modifier keys to be triggered
regKeys = [
    ("<XF86AudioMute>"       , toggleMute),
    ("<XF86AudioLowerVolume>", lowerVol),
    ("<XF86AudioRaiseVolume>", raiseVol),
    -- Prompted Search
    ("<F1>", promptWithCompl "Search" promptConfig1 promptSearchKeys ?+ -- Manual searches 
                (\searchKey -> promptSearchMap M.! searchKey)),
    -- Search using clipboard contents
    ("<F2>", promptWithCompl "Autosearch" promptConfig1 autoSearchKeys ?+ -- Clipboard searches 
                (\searchKey -> autoSearchMap M.! searchKey)),
    ("<F3>"                  , toggleMute),
    ("<F5>"                  , lowerVol)                                                   ,
    ("<F6>"                  , raiseVol)                                                   ,
    ("<F8>"                  , spawn' "xbacklight -dec 20"),
    ("<F9>"                  , spawn' "xbacklight -inc 20"),
    -- ("<F11>"                 , runOrRaise "autokey-gtk" (className =? ahkClass)), -- AHK GUI
    ("<F11>"                 , spawn "xdotool key super+k"), -- Open autokey GUI
    -- Recompile (if necessary) and restart xmonad
    ("<F12>"                 , raiseConfigAndSpawn "ghc -e ':m +XMonad Control.Monad System.Exit' -e 'flip unless exitFailure =<< recompile False' && xmonad --restart; " >> openXAtErr),
    -- Recompile and restart xmonad
    ("S-<F12>"               , raiseConfigAndSpawn "xmonad --recompile; xmonad --restart;" >> openXAtErr),
    ("<Print>"               , spawn' "selectionScreenshot"), -- Prompts for cursor drag then copies selection
    ("S-<Print>"             , spawn' "fullScreenshot"), -- Takes screenshot of all monitors
    ("C-S-<Print>"           , spawn' "uploadImage") -- Uploads screenshot to imgur
    ]
    -- TODO If there is an error compiling xmonad.hs, this stuff is supposed to open xmonad.hs on
    -- the line of the first error, doesn't fully worket yet
    where raiseConfigAndSpawn x = killXMsgAndDzen >> spawn x
          killXMsgAndDzen = spawnHere' "pkill xmessage;" {-pkill dzen-}
          focusXAtErr wlist = spawnHere' "cpXErrLn" >>
            do
              lineNum <- io $ readFile "/tmp/XErrLineNum.txt"
              unless (null lineNum) $
                do
                  (focus . head ) wlist
                  sendKey noModMask xK_semicolon
                  pasteString lineNum
                  sendKey noModMask xK_Return
          spawnXAtErr = spawnHere' $ printf "urxvt -name %s~/.xmonad/xmonad.hs -e openXAtErr" scrapPrefixStr
          openXAtErr = ifWindows isXMonadFile focusXAtErr spawnXAtErr
          isXMonadFile = resource =? (scrapPrefixStr ++ "~/.xmonad/xmonad.hs")

----------------WORKSPACES----------------
webWS   = "WEB"
termWS  = "TERM"
imWS    = "IM"
gameWS  = "GAME"
tabWS   = "ONE"
fullWS  = "FULL"
movieWS = "MOVIE"
numTermWSes = 2
termWSes = take numTermWSes $ zipWith (++) (repeat termWS) (fmap show [1..])
termWS1 = head termWSes

wses        = termWSes ++ [webWS, movieWS, tabWS, imWS, fullWS ]
mainLayout  = avoidStruts $ ResizableTall 1 (3/100) (1/2) []
webLayout   = avoidStruts $ ResizableTall 1 (3/100) (2/5) []
-- termLayout = avoidStruts $ reflectHoriz $ Mirror $ TallGrid 1 1 0.5 1 0.1
termLayout = webLayout
movieLayout = avoidStruts (ResizableTall 1 (3/100) (1/5) []) |||
              avoidStruts (reflectHoriz $ TallGrid 0 0 0 1 1)
imLayout    = avoidStruts $ reflectHoriz $ withIM (18/100) (Role "buddy_list" `Or`
                                                            Title "aoen1337 - Skype™")
                                                              G.Grid
tabLayout   = avoidStruts $ reflectHoriz $ tabbedAlways shrinkText tabTheme
fullLayout  = Full

-- Transformers
data TABBED = TABBED deriving (Read, Show, Eq, Typeable)
instance Transformer TABBED Window where
 transform TABBED x k = k tabLayout (const x)

----------------TOPICSPACES----------------
topicMap = M.fromList [
  -- ("a", 2),
  -- ("b", 2)
  -- ("sec" , 3),
  -- ("algo", 2)
  ]

myTopics = concatMap (\(x,y) -> take y (zipWith (\a b -> b ++ show a) [1..] (repeat x))) (M.toList topicMap)

myTopicConfig = defaultTopicConfig
  {
    -- topicDirs = M.fromList $
    --   [ ("someTopic", "someTopicsFullFolderPath")
    --   ]
    defaultTopicAction = const $ spawnShell >*> 3
  , topicActions = M.fromList
      [
      -- ("someTopic" , spawnHere' ("Some app") >>
      --             runTermAtDir "/some/dir" >>
      --             termExec "some script"),
      ]
  }
  where
    spawnShell = currentTopicDir myTopicConfig >>= spawnShellIn
    spawnShellIn dir = spawnHere' $ "urxvt '(cd ''" ++ dir ++ "'' && zsh )'"


-- Initializes a new topic in the current workspace
initializeCurTopic = do
  topic <- gets (W.tag . W.workspace . W.current . windowset)
  wins <- gets (W.integrate' . W.stack . W.workspace . W.current . windowset)
  when (null wins) $ topicAction myTopicConfig topic

------------------CONFIG------------------
--TODO homedir should be set in a do home <- getHomeDirectory (from import System.Directory)
homeDir                = "/home/dan/"
term                   = "urxvt"
termWinClass           = "URxvt"
-- Execute a command in a terminal
termExec cmd           = spawnHere' $ printf "%s -e zsh -c \"%s\"" term cmd
-- Execute a command in a terminal and then wait for keypress
termHold cmd           = spawnHere' $ printf "%s -e zsh -c \"%s; echo \\\"\\\\nPRESS ANY KEY TO CLOSE\\\"; read\"" term cmd
-- Execute a command ina terminal, using a prompt to first get an argument for the command
promptedTermExec promptName cmd = prompt2 promptName ?+ termExec . printf "%s %s" cmd
-- Execute a command ina terminal, using a prompt to first get an argument for the command, then
-- wait for a keypress
promptedTermHold promptName cmd = prompt2 promptName ?+ termHold . printf "%s %s" cmd
-- Execute a command (not in a terminal)
promptedSpawn promptName cmd = prompt2 promptName ?+ spawnHere' . printf "%s \"%s\"" cmd
-- Execute a command in a terminal and set the terminal's name
namedTermExec name cmd = spawnHere' $ printf "%s -name %s -e zsh -c \"%s\"" term name cmd
-- Open a terminal at a directory
runTermAtDir dir       = spawnHere' $ printf "%s -cd \"%s\"" term dir


-- Run or raise a terminal application
runOrRaiseTermApp app  = raiseMaybe (namedTermExec app app) (resource =? app)
-- If a file is already opened in vim, go to that vim instance's workspace,
-- otherwise open that file in vim
runOrRaiseVim file = raiseMaybe (namedTermExec sname ("vim " ++ file)) (resource =? sname)
             where sname = scrapPrefixStr ++ file
-- Same as runOrRaiseVim, but bring the vim instance to the current workspace instead
-- of going to the vim instance's workspace
runOrBringVim file = bringMaybe (namedTermExec sname ("vim " ++ file))
                           (resource =? sname) >> raise (resource =? sname)
                  where sname = scrapPrefixStr ++ file
-- Run or raise a gui program
runOrRaiseNext' prog winClass = rrf prog (className =? winClass)
--Opens a given url in a browser app window
runOrRaiseWebsite prog q = raiseNextMaybe (spawnHere' $ printf "/opt/google/chrome/google-chrome --app=%s" prog) (q <&&> isPopup)

-- Colors/Fonts/Sizes
fgCol            = blue
focCol           = whitePure
bgCol            = gray
errCol           = red
lapHBot          = 42
pcHBot           = 42
lapHTop          = 21
pcHTop           = 26
dzenFont         = "-*-montecarlo-medium-r-normal-*-%s-*-*-*-*-*-*-*"
dzenFontSizeLap  = 16
dzenFontSizePC   = 18
tabFont          = "-*-terminus-medium-r-normal-*-16-*-*-*-*-*-*-*"
hostifyFont size = printf dzenFont (show size)
pcFont           = hostifyFont dzenFontSizePC
lapFont          = hostifyFont dzenFontSizeLap
-- TODO Factor out, and resolutions should be read from a config file or
-- xconfig stuff
myWSBar isLaptop =
  if isLaptop then
    "dzen2 -x '6' -y 879 -w '820' -h '" ++ show lapHBot ++ "' -ta 'l' -fg '" ++ gray ++ "' -bg '" ++ black ++ "' -fn '" ++ lapFont ++ "' -p -e ''"
  else
    "dzen2 -x '6' -y 1379 -w '820' -h '" ++ show pcHBot ++ "' -ta 'l' -fg '" ++ gray ++ "' -bg '" ++ black ++ "' -fn '" ++ pcFont ++ "' -p -e ''"

-- Themes
tabTheme = defaultTheme
  { fontName            = tabFont,
    inactiveBorderColor = blackAlt,
    inactiveColor       = black,
    inactiveTextColor   = white,
    activeBorderColor   = gray,
    activeColor         = blue,
    activeTextColor     = whitePure,
    urgentBorderColor   = black,
    urgentTextColor     = red,
    decoHeight          = 22
  }

-- Map of workspace names to icon names
appIconMap = M.fromList $ [
  (webWS  , "chrome"),
  (movieWS, "vlc"),
  (tabWS  , "onews"),
  (fullWS , "fullws"),
  (imWS   , "pidgin")
  ] ++
  fmap (\x -> (termWS ++ show x, "term")) [1..10]
iconStr suffix txtFormatter str = if isJust iconFile then
                                    printf "^i(%s%s%s%s.xpm)" homeDir "bin/resources/icons/xpm/"
                                           (fromJust iconFile) suffix
                                  else
                                    txtFormatter str
                        where iconFile = M.lookup str appIconMap

-- Use different icons depending on the status of the workspace (current,
-- non-current, has an alert, etc).
iconify    = iconStr ""     (dzenColor focCol black)
iconifyAlt = iconStr "-alt" (dzenColor fgCol  black)
iconifyOff = iconStr "-off" (dzenColor bgCol  black)
iconifyUrg = iconStr "-urg" (dzenColor errCol black)

-- Status Bar Details
myPP handle = defaultPP {
      ppCurrent         = iconify,
      ppVisible         = iconifyAlt,
      ppUrgent          = iconifyUrg,
      ppSep             = printf "^fg(%s) | " gray,
      ppWsSep           = "  ",
      -- ppTitle           = dzenColor focCol black . arrow . dzenEscape,
      ppTitle           = blank,
      ppHidden          = iconifyOff,
      ppHiddenNoWindows = iconifyOff,
      ppLayout          = blank,
      ppOutput          = hPutStrLn handle,
      ppSort            = ppSort defaultPP
    -- ppSort = fmap (.scratchpadFilterOutWorkspace) $ ppSort defaultPP
    --PRINTS NAME OF LAYOUT , ppLayout       = dzenCol focCol black
 }
   where blank = const ""
   -- where noScratchPad ws | ws == "NSP" = "" | otherwise = ws

-- Hook to create urgency notifications when apps send an urgency message
myUrgencyHook = dzenUrgencyHook {
      duration = seconds 3,
      args = [
        "-bg", red,
        "-fg", whitePure,
        "-fn", pcFont,
        "-ta", "c",
        "-sa", "c"
      ] }

------------------PROMPTS--------------------
myXPConfig = Prompt.defaultXPConfig {
  Prompt.bgColor           = "black",
  Prompt.fgColor           = white,
  Prompt.fgHLight          = "black",
  Prompt.bgHLight          = blue,
  Prompt.font              = "xft:Profont:pixelsize=15:autohint=true",
  Prompt.borderColor       = blue,
  Prompt.historySize       = 0,
  Prompt.autoComplete      = Nothing,
  Prompt.promptBorderWidth = 2,
  Prompt.position          = Prompt.Top,
  Prompt.height            = 50,
  Prompt.promptKeymap      = M.insert (controlMask, xK_v) Prompt.pasteString Prompt.defaultXPKeymap
}

-- Primary Prompt
promptConfig1 = myXPConfig {
  Prompt.autoComplete = Just 0,
  Prompt.bgColor           = "grey22",
  Prompt.fgColor           = "grey80"
}

-- Secondary Prompt (used when multiple prompts are required for a command
-- to distinguish the prompt from the primary prompt)
promptConfig2 = myXPConfig {
  Prompt.autoComplete = Just 0
}

------------------FINAL-------------------
myKeyBinds =
  addManyMetaKeys [appKeys, scriptKeys, xmonadKeys] ++ regKeys

-- Key B
myKeys conf = mkKeymap conf myKeyBinds

-- Workspace Layout Bindings
myLayout = smartBorders
           $ mkToggle1 TABBED
           $ onWorkspace  tabWS    tabLayout
           $ onWorkspaces termWSes termLayout
           $ onWorkspace  webWS    webLayout
           $ onWorkspace  imWS     imLayout
           $ onWorkspace  movieWS  movieLayout
           $ onWorkspace  fullWS   fullLayout
           mainLayout

manageHooks = composeOne $
      vshiftGroup [(big, tabWS), (movies, movieWS), (games, gameWS), (im, imWS)] ++
      [ hasProp w -?> vshift fullWS <+> doFullFloat' | w <- full ] ++
      [ -- Regular Hooks
        isWebApp -?> vshift tabWS,
        -- isIncogBrowser -?> vshift fullWS,
        isMainBrowser <&&> isFullscreen -?> {- vshift webWS <+> -} doFullFloat',
        isFirefoxPopup -?> doCenterFloat',
        -- isFirefoxBrowser -?> vshift tabWS,
        xmonadhsHook
      ] ++
      [ -- Toggle Hooks
        -- isMainBrowser -?> toggleHook' "!viewChrome" (vshift webWS) (doShift webWS)
      ]
        where full   = ["Heroes of Newerth"]
              big    = [ {-ahkClass,-} "Gimp", "Update-manager", "Nautilus", "mutt", "Qbittorrent"]
              games  = ["Hon"]
              im     = ["Pidgin", "Skype"]
              movies = [ {-"Vlc"-} ]
              --
              doMaster       = doF W.shiftMaster -- append this to all floats so new windows always go on top, regardless of the current focus
              doFullFloat'   = doFullFloat   <+> doMaster
              doCenterFloat' = doCenterFloat <+> doMaster
              ---
              xmonadhsHook = iconName =? "xmessage" -?>
                                 ask >>= \_ -> liftX (ifWindow (iconName =? "xmonad.hs")
                                                               (raiseHook <+> liftX (raise (iconName =? "xmonad.hs") >> idHook) )
                                                               (return ())) >> idHook

myLogHook wsBar = historyHook <+> dynamicLogWithPP (myPP wsBar)

main = do
     isLaptop <- getHost
     wsBar <- spawnPipe (myWSBar isLaptop)
     checkTopicConfig myTopics myTopicConfig
     xmonad $ withUrgencyHookC myUrgencyHook urgencyConfig { suppressWhen = Visible } $ ewmh defaultConfig
       { terminal           = term,
         borderWidth        = 2,
         normalBorderColor  = black,
         focusedBorderColor = red,
         modMask            = winMask,
         startupHook        = {- spawnHere' (homeDir ++ ".xmonad/startup") >> -} setDefaultCursor xC_left_ptr >> checkKeymap defaultConfig {modMask = winMask} myKeyBinds,
         workspaces         = wses ++ myTopics,
         keys               = myKeys,
         focusFollowsMouse  = False,
         layoutHook         = myLayout,
         manageHook         = manageSpawn <+> manageHooks <+> manageDocks,
         handleEventHook    = docksEventHook,
         logHook            = myLogHook wsBar
       }

----------------EXTERNAL UTILS----------------
sudospawn x = spawnHere' $ printf "gksu \"%s\"" x
xclipToXsel = spawn' "xclip -o -selection clipboard | head -1 | tr -d \"\n\" | xsel -i -p"
pasteSelection' = xclipToXsel >> pasteSelection
raiseVol = spawn' $ "adjustVol + " ++ volIncrement
lowerVol = spawn' $ "adjustVol - " ++ volIncrement
toggleMute = spawn' "amixer -D pulse set Master 1+ toggle"

----------------CONSTANTS----------------
winMask      = mod4Mask
black        = "#020202"
blackAlt     = "#1c1c1c"
gray         = "#444444"
grayAlt      = "#161616"
white        = "#a9a6af"
whitePure    = "#ffffff"
blackPure    = "#000000"
whiteAlt     = "#9d9d9d"
magenta      = "#8e82a2"
blue         = "#3475aa"
red          = "#ff0000"
green        = "#99cc66"
volIncrement = "4"
isAHK        = className =? "Autokey-gtk"
mainBrowserClass  = "Google-chrome"
secondMainBrowserClass = "Chromium-browser"
mainBrowserCmd    = "google-chrome"
incogBrowserClass = "Chromium-browser"
scrapPrefixStr = "scr" -- Title prefix for windows that should not be focused by global window-searching

----------------QUERIES----------------
role     = stringProperty "WM_WINDOW_ROLE"
iconName = stringProperty "WM_ICON_NAME"
wmName   = stringProperty "WM_NAME"
q ?~  x = fmap (isSuffixOf x) q 
q ~?  x = fmap (isInfixOf x) q 
q !~? x = fmap (isNotInfixOf x) q 
q !=? x = q /=? x 
hasProp w = className =? w <||> title =? w
-- Given a map of appnames to workspaces, create hooks to move those apps to those workspaces
vshiftGroup = concatMap (\(apps, ws) -> [ hasProp w -?> vshift ws | w <- apps ])
isFirefoxBrowser = className =? "Firefox" <&&> iconName !~? "Private"
isFirefoxPopup = isDialog <||> ((className =? "Firefox") <&&> (resource  =? "Browser"))
isRSSReader = appName =? "cloud.feedly.com"
isCalendar  = appName =? "calendar.google.com"
isEmail     = appName =? "mail.google.com__mail_u_0"
isIconPrefix name = fmap (name `isPrefixOf`) iconName
isIconSuffix name = fmap (name `isSuffixOf`) iconName
isIncogBrowser = className =? incogBrowserClass
isFromMainBrowser = className =? mainBrowserClass {-<||> className =? secondMainBrowserClass-} -- Shares a class with the main browser (could be an app or something else)
isFromMainBrowserOrPDF = className =? mainBrowserClass <||> className =? "Evince" {-<||> className =? secondMainBrowserClass-} -- Shares a class with the main browser (could be an app or something else)
isMainBrowser = role !=? "pop-up" <&&> isFromMainBrowser -- Is Main Browser
isPopup = role =? "pop-up"
isWebApp = isPopup <&&> (isCalendar <||> isRSSReader <||> isEmail)

----------------XMONAD UTILS----------------
spawnBrowser = spawn' mainBrowserCmd
spawnChrome = spawnHere' "google-chrome"
spawnBrowserAndView = view' webWS >> spawnBrowser
-- raiseMainBrowser' = raiseNextMaybe (view' webWS) isMainBrowser
raiseMainBrowser' = view' webWS >> raiseMaybe doNothing isMainBrowser
raiseOrSpawnBrowser = raiseNextMaybe spawnBrowserAndView isMainBrowser
raiseAndDoOrSpawnBrowser = raiseAndDo spawnBrowserAndView isMainBrowser
view' = windows . viewFunc
viewFunc = W.view -- W.view or W.greedyView
doNothing = return ()
moveTo win = (windows . W.shift) win >> view' win
-- Safe quit active window
quitHandler = ifFocIs (className =? "Skype" <&&> role =? "") (spawn' "pkill skype") $
              ifFocIs (title ?~ "[+]") (sendKey noModMask xK_Escape >> pasteString ";q" >> sendKey noModMask xK_Return) $
              ifFocIs (className ~? "Heroes of Newerth") doNothing $ kill
-- Hard quit active window
altQuitHandler = ifFocIs (title ?~ "[+]") kill $
                 spawn' "xkill"

prompt1 = inputPrompt promptConfig1
prompt2 = inputPrompt promptConfig2
promptWithCompl txt conf list = xclipToXsel >> inputPromptWithCompl conf txt (Prompt.mkComplFunFromList list)
openURL url = raiseMainBrowser' >> spawn' (printf "%s %s" mainBrowserCmd url)
-- Swap the focused window with the last window in the stack.
swapBottom = W.modify' $ \c -> case c of
    W.Stack _ _ [] -> c    -- already bottom.
    W.Stack t ls rs -> W.Stack t (xs ++ x : ls) [] where (x:xs) = reverse rs
autoWebSearch engine = xclipToXsel >> raiseMainBrowser' >> selectSearchBrowser mainBrowserCmd engine
webSearch engine = xclipToXsel >> raiseMainBrowser' >> promptSearchBrowser myXPConfig mainBrowserCmd engine

-- Confirm an X action before running it
confirm :: String -> X () -> X ()
confirm msg f = prompt2 msg ?+ const f

----------------HELPER FUNCS----------------
-- Find the first empty workspace named "code<i>" for <i> some integer,
-- or create a new one
bringMaybe f qry = ifWindow qry (ask >>= doF . bringWindow) f
newTermWS :: X ()
newTermWS = withWindowSet $ \w -> do
  let wss = W.workspaces w
      cws = fmap W.tag $ filter (\ws -> termWS `isPrefixOf` W.tag ws) wss
      num = head $ [1..] \\ mapMaybe (readMaybe . drop 4) cws
      -- num = head $ [1..] \\ catMaybes (map (readMaybe . drop 4) cws)
      new = termWS ++ show num
  unless (new `elem` fmap W.tag wss) $ addWorkspace new
  windows $ W.view new
 where readMaybe s = case reads s of
                       [(r,_)] -> Just r
                       _       -> Nothing
swapToTermWS = withWindowSet $ \w ->
  when (take 4 (W.currentTag w) /= termWS) (view' termWS1)
bringAllWindows =
  confirm "Bring All Windows?" $
    withWindowSet $ \w -> do
      let wins = W.allWindows w
      mapM_(windows . bringWindow) wins
 
xmessage x = spawn' $ printf "xmessage \"%s\"" x
rrf prog query  = ifFocIs query (raiseNext query) (nextMatchOrDo History query (spawn' prog))
apply2nd f (x,y) = (x  , f y)
apply1st f (x,y) = (f x, y  )
map2 = fmap . apply2nd
map1 = fmap . apply1st

-- Replace spawn functions with my own which uses zsh instead of sh
-- spawnPID with zsh shell
spawnPID' :: MonadIO m => String -> m ProcessID
spawnPID' x = xfork $ executeFile "/bin/zsh" False ["-c", encodeString x] Nothing
spawn' :: MonadIO m => String -> m ()
spawn' x = spawnPID' x >> return ()
spawnHere' = spawnHere

getHost = do
  hostName <- nodeName `fmap` getSystemID
  return $ case hostName of
    "Dan-Laptop" -> True
    _            -> False

-- Stuff I will probably never need to touch or see
isNotInfixOf needle haystack = not $ any (isPrefixOf needle) (tails haystack)
dmenuRun        = "exe=`dmenu_run -i -nb black -nf white -sb '#ddaa11' -sf black -p 'run: ' ` && eval \"exec $exe\""
vshift = doF . liftM2 (.) viewFunc W.shift
addMetaKey modifier binds = [(modifier++"-"++fst bind,snd bind) | bind <- binds]
-- Apply a modifier for a bunch of pairs of hotkeys and the actions bound to them
addManyMetaKeys = foldr (\a b -> uncurry addMetaKey a ++ b) []
ifFocIs qry trueFunc falseFunc =
 (withFocused' $ \foc -> do
    isFocused <- runQuery qry foc
    if isFocused then trueFunc else falseFunc)
 falseFunc
-- Conditionally run an action, using a Maybe to decide.
ifJust mg f1 f2 = maybe f2 f1 mg
-- Apply an 'X' operation to the currently focused window, if there is one.
withFocused' foundF notFoundF = withWindowSet $ \w -> ifJust (W.peek w) foundF notFoundF
shiftToNext' = shiftToNext >> nextWS
shiftToPrev' = shiftToPrev >> prevWS

----------------WIP----------------
-- mses :: [MS ResizableTall]
-- mses =
  -- map (\wsid -> nullWS { wid = wsid, icon = Just "term", layout = TallGrid 2 2 1 1 1 }) termWSes ++
  -- [
  -- nullWS {
    -- wid    = "WEB",
    -- icon   = Just "chrome",
    -- layout = ResizableTall 1 (3/100) (3/5) []
  -- }
  -- ]
-- wses = map (\x -> wid x) mses
-- TODO ambiguous type
-- dirtyHack   = xmonad defaultConfig { layoutHook = id $ onWorkspace termWS tabLayout $ mainLayout }
--
-- data MS l = MS { wid :: WorkspaceId, icon :: Maybe String, layout :: (l Window), mHook :: [ManageHook], apps :: [String] }
-- nullWS = MS { wid     = mwid,
--               icon    = Nothing,
--               layout  = mainLayout,
--               mHook   = [className =? w --> vshift mwid | w <- mapps],
--               apps    = []
--             } where mapps = [] 
--                     mwid  = "SCRAP"
-- 
