# Disable retarded flow control hotkeys in terminal like ctrl+s
stty -ixon 2>/dev/null

# Pager options
vimpagerPath=~/bin/auto/thirdParty/vimpager/vimpager

# Path (non-interactive shells and root shell)
if [[ -z $PS1 || EUID == 0 ]]; then
  setopt extended_glob
  # path+=$HOME/.cabal/bin
  path+=($HOME/bin/**/*(/))
  unsetopt extended_glob
fi

useVimPager=false
if $useVimPager && [[-f $vimpagerPath ]]; then
  :
  # export PAGER=$vimpagerPath
else # use less
  export PAGER="less -rR" #R is for correctly interpretting ASCII color escapes
  # Colors for man
  export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
  export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
  export LESS_TERMCAP_me=$'\E[0m'           # end mode
  export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
  export LESS_TERMCAP_ue=$'\E[0m'           # end underline
  export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline
fi

export GREP_OPTIONS='-I --color=auto --exclude="*.pyc" --exclude-dir=".svn" --exclude-dir=".hg" --exclude-dir=".bzr" --exclude-dir=".git"'

# Don't add to path if root
# if (( EUID )); then
  #Add all directories in bin recursively to path
  # setopt extended_glob
  # path+=($HOME/bin/**/*(/))
  # unsetopt extended_glob
# fi

skip_global_compinit=1
