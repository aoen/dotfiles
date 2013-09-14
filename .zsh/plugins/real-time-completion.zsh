#!/usr/bin/zsh

# based on
#  incremental completion for zsh
#  by y.fujii <y-fujii at mimosa-pudica.net>, public domain

zle -N self-insert      self-insert-incr
zle -N backward-delete-char backward-delete-char-incr
zle -N magic-space magic-space-incr

# to increase the incr-0.2 max matches
export INCR_MAX_MATCHES=60

function limit-completion () {
   # got the line comparing with LINES from
   #  /usr/share/zsh/5.0.2/functions/Zle/incremental-complete-word
   local list_lines
   list_lines=$compstate[list_lines]
   {
   setopt localoptions xtrace verbose
   echo "started limit-completion"
   echo "compstate[list_lines]: $compstate[list_lines]"
   echo "INCR_MAX_MATCHES: ${INCR_MAX_MATCHES:-20}"
   echo "BUFFERLINES: $BUFFERLINES"
   echo "list_lines: $list_lines"
   echo "expr list_lines: $(expr $list_lines + $BUFFERLINES + 2)"
   echo "----- no idea why these below lines do not work"
   echo "4: $(expr ${compstate[list_lines]})"
   echo "5: $(expr $compstate[list_lines])"
   echo "6: $(expr $compstate[list_lines] + $BUFFERLINES)"
   echo "7: $(expr $compstate[list_lines] + $BUFFERLINES + 2)"
   echo "----- no idea why the above lines do not work"
   echo "LINES: $LINES"
   echo "ended limit-completion"
   # if ((compstate[list_lines] > ${INCR_MAX_MATCHES:-20} \
   #      || compstate[list_lines]+BUFFERLINES+2 > LINES))
   if [[ "$list_lines" -gt "${INCR_MAX_MATCHES:-20}" \
         || $(expr $list_lines + $BUFFERLINES + 2) -gt "$LINES" ]]
   then
      compstate[list]=''
      zle -M "too many matches."
   fi
   }  2>>| /tmp/zsh-limit-completion.log 1>&2
}

function self-insert-incr () {
   # echo "started self-insert-incr"
   if zle .self-insert; then
      show-choices
      # complete-word-incr
   fi
}

function backward-delete-char-incr () {
   if zle .backward-delete-char; then
      show-choices
      # complete-word-incr
   fi
}

function magic-space-incr () {
   if zle .magic-space; then
      show-choices
      # complete-word-incr
   fi
}

function show-choices () {
   setopt localoptions
   unsetopt BANG_HIST
   # setopt xtrace verbose
   # do not list-choices if there is a ! in that word
   #  but, as I could not figure out the word vs line,
   #  just skipping on any line with a !
   # do not list-choices if it is a paste, pending > 0 in such cases
   # do not list-choices if editing in the middle of a word
   if [[ "$BUFFER" != *\!* \
         # && "${BUFFER:0:2}" != "j " \
         # && "${BUFFER:0:2}" != "v " \
         && "$PENDING" -eq 0  \
         && ( -z "$RBUFFER" || "$RBUFFER[1]" == ' ' ) \
         ]] then
      comppostfuncs=(limit-completion)
      zle list-choices
   fi
}

function complete-word-incr () {
   local cursor_org
   local buffer_org
   local cursor_now
   local buffer_now
   local lbuffer_now
   cursor_org="$CURSOR"
   buffer_org="$BUFFER"
   comppostfuncs=(limit-completion)
   zle complete-word
   cursor_now="$CURSOR"
   buffer_now="$BUFFER"
   lbuffer_now="$LBUFFER"
}
