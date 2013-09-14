#******************************
#* Helper Functions
#******************************
# Created an alias on the condition that a particular command exists
# Use: elias alias-name not-always-available-command
elias () { exists $2 && alias $1="$2" }
# "alias" has annoying syntax because it can't have spaces before/after equal sign, use mlias
# instead
mlias () { alias $1=$2 }

# "func" is shorter than "function", same for xists and exists, helps keep things nicely aligned
mlias func function
mlias xists exists

#******************************
#* Global Aliases
#******************************
alias -g \
  ...='../..' \
  H=" | head " \
  L=" | less" \
  G=" | grep" \
  NULL=" &>/dev/null" \
  W=" | wc -l"

#*********************************************
#* Suffix Aliases (how to open file types)
#*********************************************
alias -s \
  {deb,ogg,flac,mpg,mpeg,avi,ogm,wav,wmv,m4v,mp4,mov,mkv,c,cc,cpp,h,hs,java,txt,doc,docx,rtf,odp,odt,ppt,pptx,gif,GIF,jpg,JPG,jpeg,JPEG,png,PNG,svg,htm,html,php,com,net,org,gov,mp3,ts,pdf,ps,PDF,PS}="xdg-open" \
  {7z,bz2,gz,rar,tar,zip,tgz}="myunzip" \
  git="git clone" \
  jar="java -jar" \
  log="tail -f "

#******************************
#* Packaging Aliases
#******************************
mlias autorm       "sudo apt-get autoremove"
mlias changelog    "sudo apt-get changelog"
mlias easy_install "sudo easy_install"
mlias i            "sudo apt-get install -y"
func  ppa {         sudo apt-add-repository -y "$1"; sudo apt-get update; sudo apt-get upgrade -y }
mlias purge        "sudo apt-get purge"
mlias update       "sudo apt-get update"
mlias upgrade      "sudo apt-get dist-upgrade"
mlias version      "sudo apt-cache policy"

#******************************
#* LS
#******************************
mlias lsbase "/bin/ls --color=always -CXx" # List in column, sort by extension and alphabetically

mlias la     "lsbase -a" # All files (including dotfiles)
mlias lb     "lsbase -hlS **/*(Lm+2)" # All files bigger than 2mb
mlias ld     "lsbase -d *(-/)" # Only directories
# Only hidden files (extra logic is to make sure we don't show a "." if there are no hidden files
func  lh {    res=`lsbase -d .*`; [[ $res != "[0m[01;34;35m.[0m" ]] && echo $res }
mlias le     "unsetopt null_glob; lsbase -a **/*(.L0); setopt null_glob" # List empty files
mlias led    "print -rl -- *(\^F)" # List empty directories
mlias lf     "lsbase *(.)" # Only Files
mlias ll     "lsbase -l *(@)" # Only Links
mlias ls     "lsbase --group-directories-first"
mlias l      "ls" # 1 character < 2 characters
mlias lv     "lsbase -alh" # Verbose, show perms, alphabetical order
mlias bl     "lb | tac" # Big files (reverse order)
mlias new    "lsbase -tc1 | head -n 20; e 'OLDEST'" # Newest last
mlias old    "echo 'NEWEST'; lsbase -tc1 | tac | head -n 20" # Newest first
mlias tree   "tree -C $* | less -R" # List all files recursively in a tree structure

#******************************
#* Navigation
#******************************
mlias .. "cd .." # Go one directory up
# Go to the previous directory in this terminal (for new terminals goes to the last directory in
# all terminals)
mlias b "popd 2>/dev/null || cldir && echo '' > \"$HOME/.last_dir\""
  func cldir { c "`cat "$HOME/.last_dir"`"; } # Helper function, cd to the last directory we were in
# Better cd
func c {
  # cd /some/path/some.file becomes cd /some/path/
  if [[ -f ${1} ]] then [[ ! -e ${1:h} ]] && return 1
    print "Correcting ${1} to ${1:h}"
    builtin cd ${1:h}
  else
    builtin cd ${1}
  fi
}
mlias cell   "$HOME/bin/cell/mountcell; c /media/cell" # Cell phone
mlias kindle "usb"
mlias tmp    "cd /tmp"
mlias toSort "cd ~/pictures/toSort"
mlias usb    "cd /media/usb" # Open most recently plugged in usb

#******************************
#* File Manipulation
#******************************
mlias barevim "vi -u NONE" # vim with no frills or plugins
mlias barezsh "zsh -f" # zsh with no frills or plugins
func  cdnew {  c `/bin/ls -tc1d *(-/) | head -1` } # cd into the newest directory
mlias chown   "chown --preserve-root"
mlias chmod   "chmod --preserve-root"
mlias chgrp   "chgrp --preserve-root"
func  clear {  ([ -e $1 ] && : > $1) || printf "\033c" } # Clear the contents of a file, or if no file is specified clear the screen
mlias ln      "ln -is" # ln should soft link by default
mlias hl      "\ln -i" # Hard link
mlias mv      "mv -i"
mlias cp      "cp -ir"
mlias cpv     "rsync -poghb --backup-dir=/tmp/rsync -e /dev/null --progress --" # Verbose cp (show progress)
mlias mkp     "mkdir -p"
func  mvup {   mv * .* .. && rmdir $PWD && cd .. } # Move all files in current directory up, and delete current directory
mlias mvv     "cpv"
mlias u+x     "chmod u+x" # Make a file execuable
func  pack {  tar -cvf "$1.tar" "$1" } # Compress a file or a folder
mlias qmv     "qmv --format='do'" # Batch rename using vim
elias rm       myrm # Don't delete files, instead move them to a trash folder
mlias rmd     "rmdir"
mlias srm     "srm -ll" # Less secure, but faster
mlias prm     "\rm -I --preserve-root"
xists rsync && \
mlias sync    "rsync --info=progress2 -vruP"
func txt2pdf {
  enscript -B --margins=10:10: -o outputfile.ps -f Courier@7.3/10 $1
  ps2pdfwr outputfile.ps ${1%.*}.pdf
  /bin/rm outputfile.ps
}
# Use graphical diff if one exists
func diff { if [[ $# -eq 0 ]]; then; gdiff; else; mydiff $@; fi; }
if xists meld; then
  func mydiff { meld > /dev/null $@ }
elif xists grc; then
  func mydiff { colourify \diff $@ }
fi

#******************************
#* Informational
#******************************
mlias customPackages "comm -23 <( dpkg --get-selections | awk '$2 ~ /^(install|hold)/ { print $1 }' | sort ) <( awk '{ print $1 }' ubuntu-13.04-desktop-i386.manifest | sort )"
func  bitrate {  file $1 | grep -o "[0-9]* kbps" } # Display bitrate of a file
func  count {   [[ $# -eq 0 ]] && 1="./"; find "$1/" -type f | wc -l } # Count how many files match a glob recursively
mlias disk     "df -kTh"
mlias eyedrop  "gcolor2"
func  flip {   [[ $((RANDOM % 2)) == 0 ]] && echo TAILS || echo HEADS } # Flip a coin
mlias gh       "history 0 | grep"
mlias h        "history 0"
mlias hardware "hwinfo | less"
mlias hg       "gh"
mlias info     "apt-cache search" # Print package description
func  ip {      ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1' | tail -n 1 } # Print my IP
mlias man      "betterman" # man, which, alias, --help, and more, rolled into one cmd
# Display most frequently used commands
func  mfu {
  if [[ $# -eq 0 ]]; then;
    numResults=10
  else
    numResults=$1;
  fi
  history 1 | \
    awk '{a[$2]++} END{for(i in a){printf "%5d\t%s\n",a[i],i}}' | \
    sort -rn | \
    head -n $numResults
}
# Print information about the OS
mlias os       "sudo cat /etc/issue && sudo getconf LONG_BIT; uname -av"
mlias owner    "/usr/bin/stat -c '%U'"
mlias modified "/usr/bin/stat -c '%y'"
mlias group    "/usr/bin/stat -c '%G'"
mlias playlist "mpc playlist" # Print currently playing playlist
func  size {    du -sch $@ | sort } # Print the size of a file or dolfer
xists baobab &&
mlias space    "baobab . &"
mlias tail     "tail -f" # Update tail
 # Execute a program periodically, highlight differences between occurrences
mlias watch    "watch -d -n 1"
mlias webip    "dig +short myip.opendns.com @resolver1.opendns.com"
# Cleaner xev, only show key codes, not other crap
func  xev      { /usr/bin/xev | \
                   grep -A2 --line-buffered '^KeyRelease' | \
                   sed -n '/keycode /s/^.*keycode \([0-9]*\).* (.*, \(.*\)).*$/\1 \2/p'
               }

#******************************
#* Internet
#******************************
func  dl    {    print -z `download $@` } # DL from ssh session
func  share {    ipaddr=`ip`; echo "URL: "$ipaddr:8000; python -m SimpleHTTPServer }
mlias ssh       "autossh"
mlias speedtest "wget --output-document=/dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip"

#******************************
#* System Control
#******************************
mlias changemac  "sudo macchanger -a wlan0; sudo macchanger -a eth0" # Get a new random MAC address
mlias mic        "alsamixer -V capture"
mlias mix        "alsamixer"
mlias pk         "pkill"
mlias reboot     "sudo /sbin/reboot"
mlias rec        "record"
func  restart {   sudo service "$1" restart }
mlias services   "sudo bum"
mlias shutdown   "sudo /sbin/shutdown -h now"
mlias ss         "sudo service"
func  start {     sudo service "$1" start }
func  stop {      sudo service "$1" stop }
mlias take       "sudo chown -R $(whoami):$(whoami)" # Take ownership of file or directory
mlias wifi       "sudo wicd-client -n" # alias wifi="sudo nm-connection-editor"
mlias windows    "sudo grub-reboot 5 && reboot" # Reboot into windows
mlias xmodmaps   "xmodmap $HOME/.xmodmap" # Enablexmodmap
mlias xmodmapr   "setxkbmap" # Disable xmodmap

#******************************
#* Apps
#******************************
func  feh {     /usr/bin/feh $@ & } # Recursively open every image in the current directory with feh
func  fehnew {  if [[ $# == 0 ]]; then; 1=10; fi; print -rl -- $HOME/pictures/**/*(.Dom[1,$1]) | feh -Z -f- & } # Look at newest images
mlias feh2     "feh -tX -E 256 -y 256 -W 2000 -H 1200" # Feh with thumbnails
mlias gimp     "gimp &"
mlias nautilus "nautilus --no-desktop $HOME" # Prevent nautilus from launching the gnome desktop
mlias py       "ipython"
mlias scheme   "drracket &"
func  vlc {     /usr/bin/X11/vlc --fullscreen -f $@ } 

#******************************
#* Sudo Apps
#******************************
mlias bum      "sudo bum" # Enable/disable services
mlias gparted  "sudo gparted" # Partition managament
mlias su       "sudo su -p"

#******************************
#* Misc/To Categorize
#******************************
func  alarm {    echo "urxvt -e alarmloop" | at $1 }
mlias cl        "clang++"
mlias e         "builtin echo" # Shorter version of echo
mlias fstab     "sudo vim /etc/fstab"
mlias incog     "unset HISTFILE"
func  s {        if [[ $# == 0 ]]; then; sudo $(history -p '!!'); else; sudo "$@"; fi }
func  scrapdir { tmpdir=$RANDOM && mkdir /tmp/$tmpdir && cd /tmp/$tmpdir }
mlias sv        "sudo vim"
mlias t         "timerSeconds"
mlias tm        "timerMinutes"
mlias th        "timerHours"
mlias unrarmany "find -type f -name '*.rar' -exec unrar x {} \;"
mlias va        "vi **/*(.)"
func  vb {       cd $HOME/bin/ && vf "$@" } # Open files with names matching a pattern in my scripts
func  vg {       vi `grep -rl "$1"` } # Open files in current directory containing pattern
# Opens all source files in the current directory
func  vs {       setopt NULL_GLOB; vi *.cc *.cpp *.h *.java *.hs *.sh *.py; unsetopt NULL_GLOB }

#******************************
#* Git
#******************************
mlias add       "git add"
mlias blame     "git blame"
mlias branch    "git branch"
mlias delbranch "git branch -d"
mlias checkout  "git checkout"
mlias clean     "git clean"
mlias cmt       "git commit -m"
mlias co        "checkout"
mlias filelog   "log -u" # Shows logs for a particular file
func  ignore {   [[ ! -e .gitignore ]] && touch .gitignore;  echo $1 >>.gitignore }
mlias init      "git init && git add . && git commit -a -m 'initial commit' && git gc"
mlias merge     "git merge"
mlias pop       "git stash pop"
mlias pull      "git pull --rebase"
mlias push      "git pull && git push"
mlias rebase    "git rebase"
mlias rebasec   "git rebase --continue"
mlias reset     "git reset --hard HEAD"
mlias revert    "git revert" #Use this and then commit if you make a mistake and commit it
mlias show      "git show"
mlias stash     "git stash"
mlias stat      "git status"
mlias tag       "git tag" # Tags a commit so you can use the tag to refer to the commit
func  cmta {     git add . && git commit -m "$1" && push }
func  log {      git log --pretty=format:'%Cblue%h%Creset%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative }
func  gdiff {    git diff }

#******************************
#* Searching
#******************************
# Search in file names AND file contents
func grepandfind { (echo "FILE NAMES:"; f "$1"; echo; echo "FILE CONTENTS:"; mygrep "$1") }
# Better version of find -name
func myfind {    find -L . -iname "*$1*" ! -iname "*.tmp" ! -iname "*.swp" 2>/dev/null | grep -i --color=always "$1" }
# Better version of grep
func mygrep {    ag -S -f --hidden "$1" 2>/dev/null } # Silver Searcher Rocks!

mlias a "grepandfind"
mlias f "myfind"
mlias g "mygrep"
# Search process names
func  p {       ps axo pid,command | grep -i $1 | grep -v "grep" | grep $1 }
# Opens the files in the current directory tree containing the pattern
# vf in home dir
func  v  {      if [[ $# -ne 0 ]]; then; cd ~ && vi **/*$1*.txt bin/**/*$1* && cd -; else; vi; fi }
# Find and open files in vim
func  vf {      if [[ $# -ne 0 ]]; then; vi **/*$1*(.); else; vi; fi }

#****************************************
#* Disable globbing for some commands
#****************************************
mlias ag       "ag -S -f --hidden" # Better options for silver searcher (e.g. case insenstivity)
for com in alias ack-grep find rsync scp i purge;
  alias $com="noglob ${aliases[$com]:-$com}"

#******************************
#* Color Support
#******************************
mlias ghci  "colorghci"
mlias hlint "hlint -c"
if xists grc; then
  func colourify { cmd="$1"; shift; grc -es --colour=auto "$cmd" $@ }
  for com in as configure g++ gas gcc make netstat ping traceroute which
    alias $com="colourify ${aliases[$com]:-$com}"
fi

# Clear screen before some commands
for com in configure g++ gcc make clang++ clang javac
  alias $com="clear; ${aliases[$com]:-$com}"

#******************************
#* Unused
#******************************
# alias tml="tmux ls"
# alias tmk="tmux kill-session -t"
#
# Disable commands for learning
# Most useful function evar
# donothing () {}
# mlias cd "echo \"Use 'c' instead.\"; donothing "
# TODO breaks some third party scripts i have (e.g. when cding into a git repo, zsh git displayer keeps saying this)
# mlias echo "echo \"Use 'e' instead.\"; donothing "
# mlias ls="echo \"Use 'l' instead.\"; donothing "
# mlias vim="echo \"Use 'vi' instead.\"; donothing "
# alias sudo="echo 'Use s instead.'"
# mlias cam    "cd /media/cell/DCIM/Camera"
# func  cpv {     pv "$1" "$2" } # Copy with progress bar
# mlias mmv      "noglob zmv -W" # Mass move (e.g. mmv *.TXT *.txt)
#Math
# mlias dec2hex "printf '%x\n' $1"
# mlias hex2dec "printf "%d\n" 0x$1"
# mlias hex2bin "TODO"
# mlias bin2dec "TODO"
# mlias bin2hex "TODO bin2dec dec2hex"
# mlias dec2bin "TODO dec2hex hex2bin"
# mlias nohup     "nohup &>/dev/null "
# func  nohup {   /usr/bin/nohup "$@" &>/dev/null & } # Don't wait for input and don't print to file
# mlias nohup    "nohup " # Allows command after nohup to be an alias
#        tm { if [[ -z `tmux -L "$1" ls 2>/dev/null` ]]; then; tmux -L "$1"; else; attach "$1"; fi; }
#TODO FIX
#        authenticate { ssh-keygen -t rsa -f ${1}; ssh-copy-id -i $HOME.ssh/${2} ${2}; ssh ${2}; } #Stops need for typing ssh password. Call with authenticate key_file_name hostname
#        authenticate { ssh-copy-id ${1}; } #Stops need for typing ssh password, call from host supplying client address, if this doesn't work revert back to old authenticate
#
#mlias v         "$HOME/bin/misc/myvim"
#slias sv        "$HOME/bin/misc/myvim" 
#mlias v         "fasd -f -t -e vim"
# mlias noPasswdSSH                "msshpass ssh -Y $wat;" 
# mlias authenticateBase   "ssh-keygen; ssh-copy-id -i $HOME/.ssh/id_rsa.pub"
# commented out because grep is so much slower than ag
# func mygrep {       (grep -r --exclude=\.\* --ignore-case --no-messages --line-number "$1" .; ) } 
# mlias j      "z" # Autojump using fasd
# mlias kindle "cd /media/kindle/documents"
