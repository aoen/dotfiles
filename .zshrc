#******************************************
#* Interactive & Non-Interactive Settings
#******************************************
# Global variables
export BROWSER="google-chrome"
export EDITOR=vim

# If not running interactively, stop right here
[[ -z "$PS1" ]] && return

# Path
setopt extended_glob
path+=($HOME/bin/**/*(/))
unsetopt extended_glob

#******************************
#* Sourcing
#******************************
# Clear all aliases (removes aliases that existed before, but were since removed)
unalias -m "*"

source $HOME/.remotes # Export hostname variables for various hosts
source $HOME/.aliases.zsh
custompath=$HOME/.custom.zsh && [[ -f $custompath ]] && source $custompath # Host-specific settinsg
# Plugins
# source $HOME/.zsh/plugins/per-directory/per-directory.zsh # Toggle history between global history
                                                          # and the history in the current dir
source $HOME/.zsh/plugins/syntax-highlighting/zsh-syntax-highlighting.zsh # Highlight some cmds
source $HOME/.zsh/plugins/real-time-completion/real-time-completion.zsh # Automcomplete as I type
source $HOME/.zsh/plugins/vim-bindings/vim-bindings.zsh # Various settings to improve vi mode
source $HOME/.zsh/plugins/last-working-dir/last-working-dir.zsh # Automatically cd into last
                                                                # directory for new terminals
. /usr/share/autojump/autojump.sh
# Too many issues with fasd
# exists fasd && eval "$(fasd --init auto)" # Start fasd

#******************************
#* Settings
#******************************
setopt always_last_prompt
setopt always_to_end # Completion within a word always moves to the end of the word
setopt append_history # Don't overwrite history, append to it
setopt auto_cd # cd with "DIR" instead of "cd DIR"
setopt auto_list # Automatically list choices on an ambiguous completion
setopt autopushd # Make cd push the old directory onto the directory stack
setopt c_bases # Prefix hex values with 0x
setopt complete_in_word # Allow tab completion in the middle of a word
setopt extended_glob
setopt glob_complete # Expland regexes with tab
setopt hist_ignore_all_dups # Prevent duplicate commands from occuring in the history
setopt hist_ignore_dups # Don't push multiple copies of the same directory onto the directory stack
setopt hist_ignore_space # Don't put cmds starting with <space> into history
setopt hist_reduce_blanks # Strip extra white space from cmds before adding them to history
setopt hist_save_no_dups
setopt ignore_eof # Do not exit on end-of-file (i.e. when ^D is pressed).
setopt inc_append_history # Write to history file after every command
setopt interactive_comments # Allow comments even in interactive shells
setopt multios # Allow redirecting to multiple files at once
setopt no_beep # Disable beeping noises
setopt no_flow_control # Prevent ^s from suspending terminal
setopt nobgnice # Do not change the nice (ie, scheduling priority) of backgrounded commands.
setopt nocheckjobs # Do not warn about closing the shell with background jobs running.
setopt nohup # Do not kill background processes when closing the shell
setopt null_glob # Do not display error when there are no matches to a glob
setopt numeric_glob_sort # Sort filenames numerically when it makes sense.
setopt pushd_ignore_dups # Prevent duplicate dirs pushed onto dir stack
setopt pushd_minus
setopt pushd_silent # No annoying pushd messages
setopt pushd_to_home # Sort filenames numerically when it makes sense.

unsetopt auto_remove_slash
unsetopt case_glob
unsetopt correct_all
unsetopt list_ambiguous
unset MAILCHECK # Don't check for new mail

# Can cd into these dirs from anywhere
# cdpath=(../ ~/)

# Restart zsh when one of the files this script depends on, including this file, are modified
trap "restartzsh" USR1
restartzsh () {
  source ~/.zshrc
  rehash
  print '\n.zshrc updated'
  zle push-line
  zle accept-line
  zle reset-prompt
}

# Save cancelled commands to history
TRAPINT () {
  zle && [[ $HISTNO -eq $HISTCMD ]] && print -rs -- $BUFFER
  return $1
}

# Enable highlighters
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern url)
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=magenta'

ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=yellow'

ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=magenta,bold'

# Highlight RM operations
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')
ZSH_HIGHLIGHT_PATTERNS+=('prm *' 'fg=white,bold,bg=red')

LISTMAX=1000 # Don't prompt to display less than 300 completions
DIRSTACKSIZE=1000
HISTSIZE=10000
SAVEHIST=10000
# Store user and root histories in different files
if (( ! EUID )); then
  HISTFILE=$HOME/.zsh_history_root
else
  HISTFILE=$HOME/.zsh_history
fi

fpath=(.zsh/plugins/completions $fpath)
autoload -Uz compinit && compinit
autoload -Uz colors && colors

# TODO Commented out because it conflicts with real-time-completions
# autoload -U url-quote-magic && zle -N self-insert url-quote-magic
autoload -Uz edit-command-line && zle -N edit-command-line
autoload zmv

# Command that is run before every prompt
function precmd {
  # Don't set title for ttys (they don't have one!)
  if [[ $TERM != "linux" ]]; then
    # Set terminal title to running command
    title+="\e]2;"
    # Indicate if this is an SSH session
    if [[ -n $SSH_TTY ]]; then
      title+="SSH "
    fi
    # Append current directory
    title+="%~"
    # Indicate root sessions
    if [[ $UID == 0 ]]; then
      title="!!! "$title" !!!"
    fi
    title+="\a"
    print -Pn "$title"
  fi
  # Globally store the current directory as the last directory visited so that other commands can
  # use this info
  [[ $my_currdir != $PWD ]] && ls && [ $PWD != ~ ] && echo $PWD > ~/.last_dir
  my_currdir=$PWD
}

# Command that is run before every command we execute
preexec () {
  # Don't set title for ttys (they don't have one!)
  if [[ $TERM != "linux" ]]; then
    print -Pn "\e]2;$1\a" # Set terminal title to running command
  fi
}

# Export variable to let other programs know whether we are a laptop or not
if [[ $HOST == "Dan-Laptop" ]]; then
  export LAP=1
else
  export LAP=0
fi

#******************************
#* Auto-complete Settings
#******************************
# When offering typo corrections, do not propose anything which starts with an
# underscore (such as many of Zsh's shell functions).
CORRECT_IGNORE='_*'

#MORE: http://zsh.sourceforge.net/Misc/compctl-examples******************************
#compdef _directories create-archive
eval $(dircolors $HOME/.dir_colors) # Add colors to completions

# Print type headers for completions
# zstyle ':completion:*:descriptions' format '%U%B%d%b%u'

# Gray out already typed characters of completions
zstyle -e ':completion:*:default' list-colors \
  'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==90=0}:${(s.:.)LS_COLORS}")'
# zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # Color completions the same way ls does

# Completion order
zstyle ':completion:*' completer _complete _list _oldlist _expand _ignored _match \
                         _prefix # _correct _approximate TODO approximate causes lag for autocompletion, and _correct makes "~/documents/randomstring<TAB>" to turn into ""

# Allow some spelling errors when completing (more for longer strings)
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'

zstyle ':completion::prefix-1:*' completer _complete
zstyle ':completion:predict:*' completer _complete
zstyle ':completion:incremental:*' completer _complete # TODO disabled until _correct is enabled in completions_correct

#Order of dirs in autocompletion
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories

#Completion caching
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path .zsh/cache/$HOST

zstyle ':completion:*' expand 'yes' #Expand partial paths
zstyle ':completion:*' squeeze-slashes 'yes' # Removes last slash if you use a directory as an arg
zstyle ':completion:*' insert-tab false
# Case-insensitive, partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
#filename suffixes to ignore during completion (except after rm command)
# TODO doesn't work (because rm is alias)
# zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.(o|c~|old|pro|zwc)' '*~'
#No binary files for less or vim
badTxt='*.(o|a|so|dvi|fig|out|class|pdf|ps|pyc|class)'
# Make certain commands complete the same way as others
# TODO a lot of these don't work
compdef vi=vim
compdef vim=vim
compdef u+x=vi
compdef c=cd
compdef clear=vi
compdef feh=feh
compdef myrm=rm
compdef cp=rsync

# ANTI-COMPLETIONS (completions to exclude)
  zstyle ':completion:*:*:*' ignore-line yes # Don't complete stuff already on the line
  zstyle ':completion:*' ignore-parents parent pwd # Don't complete ../<TAB> to current_dir
  zstyle ':completion:*:functions' ignored-patterns '_*' # Ignore completion functions
  zstyle ':completion:*:less:*' ignored-patterns zstyle ':completion:*:vim:*' ignored-patterns $badTxt
  zstyle ':completion:*:vi:*' ignored-patterns $badTxt
  zstyle ':completion:*:diff:*' ignored-patterns $badTxt
  zstyle ':completion:*:clear:*' ignored-patterns $badTxt

#TODO get below working
# rm: advanced completion (e.g. bak files first)
# zstyle ':completion::*:rm:*:*' file-patterns '*.o:object-files:object\ file *(~|.(old|bak|BAK)):backup-files:backup\ files *~*(~|.(o|old|bak|BAK)):all-files:all\ files'
# vi: advanced completion (e.g. tex and rc files first)
# zstyle ':completion::*:vi:*:*' file-patterns 'Makefile|*(rc|log)|*.(php|tex|bib|sql|zsh|ini|sh|vim|rb|sh|js|tpl|csv|rdf|txt|phtml|tex|py|n3):vi-files:vim\ likes\ these\ files *~(Makefile|*(rc|log)|*.(log|rc|php|tex|bib|sql|zsh|ini|sh|vim|rb|sh|js|tpl|csv|rdf|txt|phtml|tex|py|n3)):all-files:other\ files'

# Autocomplete sudo commands like regular ones (breaks other ones)
# zstyle -e ':completion:*:sudo:*' command-path 'reply=(~/bin $path /usr/local/bin /opt/bin)'

#Kill processes
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
# use /etc/hosts and known_hosts for hostname completion
[ -r /etc/ssh/ssh_known_hosts ] && \
  _global_ssh_hosts=(${${${${(f)"$(</etc/ssh/ssh_known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
[ -r ~/.ssh/known_hosts ] && \
  _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
[ -r /etc/hosts ] && : \
  ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} \
  || _etc_hosts=()
hosts=(
  "$_global_ssh_hosts[@]"
  "$_ssh_hosts[@]"
  "$_etc_hosts[@]"
  "$HOST"
  localhost
)
# _fasd_zsh_cmd_complete() {
  # local compl
  # read -c compl
  # (( \$+compstate )) && compstate[insert]=menu # no expand if compsys loaded
  # reply=(\${(f)"\$(fasd --complete "\$compl")"})
# }

# zle -C myvim complete-word _generic
# zstyle ':completion:*:myvim:*' completer _fasd_zsh_word_complete_f
# zstyle ':completion:myvim:*' menu-select
zstyle ':completion:*:hosts' hosts $hosts
# Don't keep suggesting file / pid if it is on the line already
zstyle ':completion:*:(rm|kill|diff):*' ignore-line yes

# Less users
users=(dan root)
zstyle ':completion:*' users $users

#******************************
#* Bindings
#******************************
# Use vim keybindings
# bindkey -v

bindkey " "    magic-space
bindkey "^e"   insert-last-word
bindkey "^h"   beginning-of-line
bindkey "^l"   end-of-line
bindkey "^r"   copy-prev-shell-word # Duplicate; the last placed word
bindkey "^[[Z" reverse-menu-complete # Shift-tab to cycle completions backwards
# Search for string with current prefix in history
  bindkey "^p" history-beginning-search-backward
  bindkey "^n" history-beginning-search-forward
# Search for string with current substring in history
  bindkey "^u" history-incremental-search-backward
  bindkey "^@" history-incremental-search-forward
bindkey "^x"   edit-command-line
bindkey "^w"   quit # C-w quits
bindkey "^o"   per-directory-history-toggle-history # Toggle per-directory history
bindkey "^Q"   run-last-command # Run command but keep in buffer
 # Reruns last command with the first numeric argument inc/decremented
  bindkey "^\\" dec-and-rerun # C-4
  bindkey "^]"  inc-and-rerun # C-5
bindkey '^I'   expand-twice

# Need to do it twice for autocompletion (otherwise ~/doc<TAB> will not show directories in
# ~/documents until tab is pressed again)
function expand-twice() {
  if [[ -z $BUFFER ]]; then
    BUFFER="./"
    zle end-of-line
    zle expand-or-complete
  else
    zle expand-or-complete
    firstchr=${BUFFER:0:1}
    lastchr=${BUFFER#${BUFFER%?}}
    if [[ "$lastchr" = "/" ]] && [[ "$firstchr" != "." ]] then
      zle list-choices
    fi
  fi
}
zle -N expand-twice

# Quit terminal
function quit() {
  exit
}
zle -N quit

# Substitutes the first filename in the last command with the filename preceding it lexically
function dec-and-rerun() {
  # Search in history until we get a line with a number in it
  zle history-beginning-search-backward
  tmp=`tempfile`
  echo ${BUFFER:2} | sed 's/\\//g' > $tmp
  target=`cat $tmp`
  /bin/rm $tmp
  atNextEntry=false
  /bin/ls -1 | sort -r | while read fileName; do
    if $atNextEntry; then
      safeFileName=`echo $(printf '%q' $fileName)`
      BUFFER=./$safeFileName
      break
    fi
    if [ $fileName = $target ]; then
      atNextEntry=true
    fi
  done
  zle accept-line
}
zle -N dec-and-rerun

# Substitutes the first filename in the last command with the filename following it lexically
function inc-and-rerun() {
  # Search in history until we get a line with a number in it
  zle history-beginning-search-backward
  tmp=`tempfile`
  echo ${BUFFER:2} | sed 's/\\//g' > $tmp
  target=`cat $tmp`
  /bin/rm $tmp
  atNextEntry=false
  /bin/ls -1 | sort | while read fileName; do
    if $atNextEntry; then
      safeFileName=`echo $(printf '%q' $fileName)`
      BUFFER=./$safeFileName
      break
    fi
    if [ $fileName = $target ]; then
      atNextEntry=true
    fi
  done
  zle accept-line
}
zle -N inc-and-rerun

# Run last command
function run-last-command {
  BUFFER="!!"
  zle history-beginning-search-backward
  zle accept-line
}
zle -N run-last-command

# Enter on new line = repeat last command
# function empty-buffer-to-ls() {
    # if [[ $#BUFFER == 0 ]]; then
        # BUFFER="!!"
    # fi
# }
# zle -N zle-line-finish empty-buffer-to-ls

#*****************************
#* Prompt
#*****************************
source $HOME/.zsh/plugins/git-prompt/zshrc.sh
vimmodecol=$fg_bold[white]
nowritepermscol=$fg_bold[red]
if [[ $HOST == "some ssh host" ]]; then # Special SSH hosts
  maincol=$fg_bold[green]
  pre=`e $HOST | /bin/grep -o "[1-9]*"`":"
elif [[ $EUID -eq 0 ]]; then # root
  maincol=$fg_bold[red]
else # Regular user
  maincol=$fg_bold[blue]
fi

# Color end of prompt differently depending on if the user has write permissions to the cur dir
function permisionscolor {
  if [[ ! -w "${PWD}" ]]; then
    echo %{${nowritepermscol}%}
  else
    echo %{${maincol}%}
  fi
}

# Use cyan color for the prompt when in vi mode, and a blue color otherwise
function modecolor {
  if [[ $vim_mode == $vim_ins_mode ]]; then
    echo %{${maincol}%}
  else
    echo %{${vimmodecol}%}
  fi
}

PROMPT='$(modecolor)$pre%~%b$(git_super_status)$(permisionscolor)$%{$maincol%}%{$reset_color%} '
