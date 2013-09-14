"******************************
"* Plugins
"******************************

"Vim package manager that handles all these bundles
set nocompatible
if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif
call neobundle#rc(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'Shougo/vimproc'

NeoBundle 'Valloric/YouCompleteMe' "Tab-Completion for various programming languages
NeoBundle 'Valloric/ListToggle' "Show list of compile errors
NeoBundle 'godlygeek/tabular' "Line up commas and other text
NeoBundle 'dag/vim2hs' "Extra haskell features
NeoBundle 'klen/python-mode' "Extra python features
NeoBundle 'tpope/vim-endwise' "Autoend some structures
NeoBundle 'tpope/vim-surround' "Surround objects with quotes
NeoBundle 'tomtom/tcomment_vim' "Comment lines out
NeoBundle 'tpope/vim-repeat' "Makes the . key work with a lot of plugins
NeoBundle 'PeterRincker/vim-argumentative' "Swap function arguments
"DEPENDENCIES
  NeoBundle 'MarcWeber/vim-addon-mw-utils'
  NeoBundle 'tomtom/tlib_vim'
  NeoBundle 'Shougo/unite.vim'
"FILE MANIPULATION
  NeoBundle 'kien/ctrlp.vim' "Open files with fuzzy finding
  NeoBundle 'vim-scripts/Rename' "Rename current file
  NeoBundle 'vim-scripts/RemoveFile.vim' "Delete current file
  NeoBundle 'tpope/vim-obsession' "Better session management
"TEXT OBJECTS
  NeoBundle 'kana/vim-niceblock' "Allows selecting blocks of text and then using A and I (more intuitive A and I)
  NeoBundle 'kana/vim-textobj-user'
  NeoBundle 'bkad/CamelCaseMotion'
  NeoBundle 'glts/vim-textobj-comment'
  NeoBundle 'kana/vim-textobj-function'
  NeoBundle 'michaeljsmith/vim-indent-object'
  NeoBundle 'paradigm/TextObjectify' "List object (e.g. di,)
"NAVIGATION
  NeoBundle 'teranex/jk-jumps.vim' "Make j/k count as jumps so jumping to previous lines works as expected
  NeoBundle 'Lokaltog/vim-easymotion' "Jump to certain letters quickly
  NeoBundle 'lambacck/python_matchit' "Make % operator work for python blocks (since it has no braces)
  NeoBundle 'dbakker/vim-paragraph-motion' " { and } not only matches blank lines, but also lines with only whitespace
"AESTHETICS
  NeoBundle 'lilydjwg/colorizer' "Colorize color codes in files
  NeoBundle 'gregsexton/MatchTag' "Highlight matching tags in html
  NeoBundle 'scrooloose/syntastic' "Syntax highlighting for various languages
  NeoBundle 'dbakker/vim-lint' "Error highlighting for vimrc
  NeoBundle 'tomtom/quickfixsigns_vim' "Colored sidebar markers (e.g. compilation errors)
  NeoBundle 'mhinz/vim-signify'

filetype plugin indent on

" Make % match more things
runtime macros/matchit.vim

"******************************
"* Settings
"******************************
"Omnicomplete
  set ofu=syntaxcomplete#Complete completeopt=longest,menuone matchtime=3
"Paste Toggle (toggle + C-S-v + toggle)
  set pastetoggle=<Insert>
"Stop beeping and screen flashing on errors
  set noerrorbells novisualbell t_vb=
"Make backspace work
  set bs=2
"Make underscore delimit words
  set iskeyword-=_
"Better CLI completion
  set wildmenu wildmode=list:longest,list:full
"Search
  set incsearch ignorecase smartcase hlsearch gdefault
"Status Line
  set ruler laststatus=2 "Always display the status line
"Backups
  set backupdir=$HOME/.vimback// directory=$HOME/.vimback//
"Folds
  set viewdir=~/.vimviews "Where cursor position and other info for each file is stored
  " set viewoptions=folds,options
"Undo even after closing a file
  set undofile undodir=$HOME/.vimundo
  set undolevels=1000 " How many undos
  set undoreload=10000 " Number of lines to save for undo
set autoread "Automatically reload if changes detected
" set autowriteall "Save when focus is lost
set bufhidden=hide
set autoindent nosmartindent
" Fix slow O inserts
set timeout timeoutlen=1000 ttimeoutlen=100
set list listchars=tab:➝\ ,extends:#,nbsp:.
" Don't look at top lines for modeline
set nomodeline
set modelines=0
"Yanks go on clipboard instead
if version >= 703
  set clipboard& clipboard=unnamedplus
else
  set clipboard& clipboard=unnamed
endif
" Enable folding by indentation
  " set foldmethod=indent
  set fillchars=fold:\ ,diff:⣿
set dictionary-=/usr/share/dict/words "Dict for spellchecking
set expandtab "Tabs become spaces
set formatoptions=crql
set shiftround "Round indentation to nearest indent interval
set hidden "Hides additional buffers
set lazyredraw "Doesn't bounce around during macros and functions
set noswapfile
" set number "Line Numbers
set relativenumber "Line numbers relative to the cursor's line
set numberwidth=3
set scrolloff=3 "Minimum number of lines to keep below/above current line
set scrolljump=5 "Lines to scroll when cursor leaves screen
set shiftround "Fixes indents that aren't a multiple of shiftwidth automatically
set shiftwidth=2 "How much shift command should shift over by
"set spelllang=en
"set spellsuggest=9
set shortmess+=filmnrxoOtT "Shorter messages
" set nofoldenable " Disable folding by default
set mouse= "Disable mouse support
set tabstop=2
set tabpagemax=100
set tildeop "Make tilde work with motions
set wildignore+=*.o,*.obj,*.exe,*.so,*.dll,*.pyc,.svn,.hg,.bzr,.git,.sass-cache,*.class
set nowrap "Turn off word-wrapping
set showcmd "Show commands as you are typing them
"Set window title
  set titlestring=%f%h%r%w\ %m
  set title
" Better include path handling
  set path+=src/
  let &inc.=' ["<]'
" Set zsh as vim's shell
if filereadable('/usr/bin/zsh')
  set shell=/usr/bin/zsh
endif
"Leader Key
let mapleader   = ","
let g:mapleader = ","
"hi CursorLine ctermbg=234 "Highlight current line (inc/dec # to make lighter/darker)
"Colors
  syntax enable "Enable syntax highlighting (must come before others as to not overwrite them)
  hi SpellBad term=NONE ctermbg=124 "Make spelling mistake highlighting darker
  hi LineNr ctermfg=208 "Line number color
  " set cursorline "Underline current line
  hi CursorLine term=bold cterm=bold ctermbg=234 "Bold the Cursor Line
  hi Directory ctermfg=darkcyan
  " Right edge to stop me from typing more than X chars
  set colorcolumn=100
  set t_Co=256
  set bg=dark
  "More robust but doesn't work? if &t_Co == 256
  if $COLORTERM == 'rxvt-xpm'
    " settings for 256-color theme
    colorscheme desert256
  else
    " settings for tty
    colorscheme noctu
  endif
  match Todo /TODO/ "Hilight TODO
  " Search Colors
    hi Search ctermbg=240
    hi ColorColumn ctermbg=0 ctermbg=12
    hi Search cterm=NONE ctermbg=white ctermbg=magenta
    hi IncSearch cterm=NONE ctermfg=white ctermbg=lightBlue

" ---------------
" Status Line
" ---------------
set statusline=%t    "tail of the filename
set statusline+=%m   "modified flag
set statusline+=%r   "read only flag
set statusline+=%=   "left/right separator
set statusline+=%c,  "cursor column
set statusline+=%l   "cursor line/total lines
set statusline+=\ %P "percent through file

"******************************
"* Custom Hotkeys
"******************************
"NOTE: Hotkeys that start with <C-g> are those that I use autokey for (i.e. I
"never use th <C-g> hotkey to trigger the bound command, but rather another
"key that I have bound to that command)

"Opens URL under the cursor
" nnoremap <leader>o :silent !xdg-open <C-R>=escape("<C-R><C-F>", "#?&;\|%")<CR><CR>:redraw!<CR>
"TODO should make sure there is a URL under cursor before opening in browser
nnoremap ,o :silent silent !$BROWSER <C-R>=escape("<C-R><C-F>", "#?&;\|%")<CR><CR>

"Toggle Dictionary
nnoremap <leader>d :set spell! spell?<CR>

"Execute file being edited
nnoremap <C-r> :update<CR>:! %:p<CR>
inoremap <C-r> <ESC>:update<CR>:! %:p<CR>

"Copy filename to clipboard
nnoremap <leader>y :let @+=expand("%:p")<CR>

"Clear execute buffer between commands
noremap :! :!clear; 

"Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv 

"Combine/Split Lines
nnoremap z J
nnoremap Z i<CR><ESC>
nnoremap <C-g>z :s/\%#\(.*\)\n\(.*\)/\2\1<CR>:silent nohlsearch<CR>

"Toggle Folds
nnoremap <space> zA
vnoremap <space> zf

"Lowercase tilde changes one letter
nnoremap ` ~l

"Indent cur line
nnoremap = ==
"Indent whole file
nnoremap <C-g>i 1G=G``
inoremap <C-g>i <ESC>1G=G11.a

"Correct first spelling mistake
" inoremap <C-s> <Esc>]s1z=`]a

"Select all text
nnoremap <C-g>a ggVG
inoremap <C-g>a <ESC>ggVG

"SEARCH/REPLACE
  nnoremap \ :%s/|norm!''
  nnoremap \ :%s/\<<C-r><C-w>\>/
  "Replace with confirmations for each replacement
  nnoremap <Bar> :.,$s/\<<C-r><C-w>\>//c<Left><Left>|norm!``
  "Yank till end of line
  nnoremap <S-y> y$
  "Search for selected text, forwards or backwards.(How is this better than the original ones?)
  vnoremap <silent> * :<C-U>
    \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
    \gvy/<C-R><C-R>=substitute(
    \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
    \gV:call setreg('"', old_reg, old_regtype)<CR>
  vnoremap <silent> # :<C-U>
    \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
    \gvy?<C-R><C-R>=substitute(
    \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
    \gV:call setreg('"', old_reg, old_regtype)<CR>

"NAVIGATION
  " My muscle memory has these shortcuts swapped for some reason
  nnoremap G  gg
  nnoremap gg G

  ":n goes to line n
  nnoremap : <Bar>

  " Jump to last/next edit
  nnoremap <C-g>'1 g;
  nnoremap <C-g>'2 g,
  " Jump to last/next line in history
  nnoremap ' <C-o>
  nnoremap " <C-i>

  " TODO conflicts with paragraph motion binding
  "[ / ] go to next/prev empty lines
  " nnoremap } {
  " nnoremap { }
  " nnoremap ] {
  " nnoremap [ }

  "Scroll by half a page or so
  nnoremap J <C-d>
  nnoremap K <C-u>
  vnoremap J <C-d>
  vnoremap K <C-u>

"Stamping (replace inner word with yanked word)
nnoremap s :let "_diwhp
vnoremap s "_dp

"Saving/exiting
" cmap w!! w !sudo dd of=%<CR>
cnoremap w!!<CR> silent :w !sudo tee % >/dev/null<CR>
nnoremap <C-g>s1 :update<CR>
inoremap <C-g>s1 <ESC>:w<CR>a
vnoremap <C-g>s1 <ESC>:w<CR>gv
nnoremap <C-g>s2 :Rename 
inoremap <C-g>s2 <ESC>:Rename 
vnoremap <C-g>s2 <ESC>:Rename 

"Rearrange function arguments 
nmap <leader>< <Plug>Argumentative_MoveLeft
nmap <leader>> <Plug>Argumentative_MoveRight

"UNMAPPINGS
  "Unmap ex mode
  map Q <nop>
  "Unmap help
  map <F1> nop
  " Make quiting more annoying so I remember to use alt+q instead of ;q!<CR>
  " cmap q<CR> nop
  " cnoremap quit<CR> q<CR>
  "Workaround because I map <Shift-Enter> to some strange key in my
  "xresources so that it will rerun the last command
  inoremap  <CR>

"IMPROVED HOTKEYS
  "Use ; for : in normal and visual mode, less keystrokes
  nnoremap ; :
  vnoremap ; :
  nnoremap : ;
  vnoremap : ;
  "Consistent redo shortcut
  nnoremap U <C-r>
  "Delete current file
  nnoremap <C-g>d2 <ESC>:Remove
  "Better hotkey for inverting case of selection
  vnoremap ` ~
  "Lowercase tilde changes one letter
  nnoremap ` ~l
  "Backspace clears highlighting
  nnoremap <Backspace> :silent nohlsearch<CR>
  "Remap increasing/decreasing numbers
  nnoremap _ <C-x>
  nnoremap + <C-a>

"Double percentage sign in command mode is expanded to directory of current file
cnoremap %% <C-R>=expand('%:h').'/'<CR>

"Enter should make new line in normal mode (otherwise pasting on line below is a pain)
nnoremap <CR> o<ESC>
  "Prevent enter mapping from messing up confirming dialogs and suchk
  autocmd CmdwinEnter * nnoremap <CR> <CR>
  autocmd BufReadPost quickfix nnoremap <CR> <CR>
nnoremap <C-g><CR> O<ESC>

"Repeat command in visual mode on multiple lines
vnoremap . :normal .<CR>

"TAB NAVIGATION/CREATION
  "Left/right
  noremap  <C-g>j :tabp<CR>
  inoremap <C-g>j <ESC>:tabp<CR>
  cnoremap <C-g>j <ESC>:tabp<CR>
  noremap  <C-g>k :tabn<CR>
  inoremap <C-g>k <ESC>:tabn<CR>
  cnoremap <C-g>k <ESC>:tabn<CR>
  "Drag Tabs left/right
  noremap  <C-g>h :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
  cnoremap <C-g>h <ESC>:execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
  inoremap <C-g>h <ESC>:execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
  noremap  <C-g>l :execute 'silent! tabmove ' . tabpagenr()<CR>
  inoremap <C-g>l <ESC>:execute 'silent! tabmove ' . tabpagenr()<CR>
  cnoremap <C-g>l <ESC>:execute 'silent! tabmove ' . tabpagenr()<CR>
  "Open file in new tab
  noremap  <C-g>t :tabedit 
  inoremap <C-g>t <ESC>:tabedit 
  cnoremap <C-g>t <ESC>:tabedit 
  "Search across open tabs TODO not working
  noremap  <C-g>f :tabfind 
  inoremap <C-g>f <ESC>:tabfind 
  cnoremap <C-g>f <ESC>:tabfind 
  "Close current tab
  noremap  <C-g>w :q<CR>
  inoremap <C-g>w <ESC>:q<CR>
  cnoremap <C-g>w <ESC>:q<CR>

"Allow deleting selection without updating the clipboard (yank buffer)
nnoremap x "_x
nnoremap X "_X
noremap <C-d> "_d

"TODO might break snippets when ycm gets them (pressing x in snippet completion uses x instead)
vnoremap x "_x
vnoremap X "_X

"Don't move the cursor after pasting
"(by jumping to back start of previously changed text)
" nnoremap p p`[
" nnoremap P P`[

""******************************
"* Hooks
""******************************
" Go to last file(s) if invoked without arguments.
autocmd VimLeave * nested if (!isdirectory($HOME . "/.vim")) |
    \ call mkdir($HOME . "/.vim") |
    \ endif |
    \ execute "mksession! " . $HOME . "/.session.vim"

autocmd VimEnter * nested if argc() == 0 && filereadable($HOME . "/.session.vim") |
    \ execute "source " . $HOME . "/.session.vim"

"Put yank buffer into xclip on leave
autocmd VimLeave * call system("xsel -ib", getreg('+'))

"Autoreloads
  autocmd BufWritePost ~/Dropbox/ubuntu/var/spool/cron/crontabs/dan silent !crontab -u dan ~/Dropbox/ubuntu/var/spool/cron/crontabs/dan
  autocmd BufWritePost ~/bin/system/fstabentries silent !sudo $HOME/bin/.helper/populatefstab && notify-send 'Updated fstab entries'
  autocmd BufWritePost ~/.Xresources silent !xrdb ~/.Xresources && notify-send 'Updated xresources'
  autocmd BufWritePost ~/.xmodmap silent !xmodmap ~/.xmodmap && notify-send 'Updated xmodmap'
  autocmd! BufWritePost ~/.vimrc source ~/.vimrc

"When editing a file, always jump to the last cursor position
autocmd BufReadPost *
      \ if line("'\"") > 1 && line ("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif

"Change/revert color when entering Insert Mode
autocmd InsertEnter * hi LineNr ctermfg=220
autocmd InsertLeave * hi LineNr ctermfg=208

"****************************************
" Plugin Configuration
"****************************************
"----------------------------------------
" CamelCaseMotion
"----------------------------------------
map <silent> W <Plug>CamelCaseMotion_w
map <silent> B <Plug>CamelCaseMotion_b
map <silent> E <Plug>CamelCaseMotion_e
"TODO don't work
omap <silent> iW <Plug>CamelCaseMotion_iw
xmap <silent> iW <Plug>CamelCaseMotion_iw
omap <silent> iB <Plug>CamelCaseMotion_ib
xmap <silent> iB <Plug>CamelCaseMotion_ib
omap <silent> iE <Plug>CamelCaseMotion_ie
xmap <silent> iE <Plug>CamelCaseMotion_ie

"----------------------------------------
" List Object
"----------------------------------------
"TODO don't work
onoremap <silent> a, aP
onoremap <silent> i, iP
vnoremap <silent> a, aP
vnoremap <silent> i, iP

"----------------------------------------
" Matchit
"----------------------------------------
let b:match_ignorecase = 1

"----------------------------------------
" jk-jumps
"----------------------------------------
"Moving at least 2 lines using j/k is recorded in jump list history
let g:jk_jumps_minimum_lines = 2

" ---------------
" YouCompleteMe
" ---------------
" Don't prompt to confirm extra configuration options file (a bit insecure if someone
" injects their own)
let g:ycm_confirm_extra_conf = 0
let g:ycm_key_detailed_diagnostics = ''

" ---------------
" ListToggle
" ---------------
"Unmap this function so Syntastic can use the binding
let g:lt_location_list_toggle_map = '<leader>9'
nnoremap <leader>L :lprev<CR>
nnoremap <leader>l :lnext<CR>

" ---------------
" Syntastic
" ---------------
" Use clang++ instead of g++
let g:syntastic_cpp_compiler = 'clang++'

" ---------------
" ctrlp.vim
" ---------------
" "disable mapping
" let g:ctrlp_map = '<c-$>'
" let g:ctrlp_max_height = 10
let g:ctrlp_max_history = 100
" " Scan unlimited files on startup
let g:ctrlp_max_files = 0
let g:ctrlp_mruf_max = 100
let g:ctrlp_mruf_relative = 0
let g:ctrlp_use_caching = 1
let g:ctrlp_follow_symlinks = 1
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_cache_dir = $HOME.'/.cache/ctrlp'
let g:ctrlp_dotfiles = 1
let g:ctrlp_cmd ='CtrlPMixed'

" ---------------
" Easy Motion
" ---------------
let g:EasyMotion_leader_key = '<Leader>'

" ---------------
" Vundle
" ---------------
" Install/Uninstall
nnoremap <Leader>ni :Unite neobundle/install:!<CR>
nnoremap <Leader>nc :NeoBundleClean<CR>
" Non-async update
" nnoremap <Leader>bi :NeoBundleInstall!<CR>

" ---------------
" Tabularize
" ---------------
" Tabularize based on commas
nnoremap <C-g>,1 :Tab /,<CR>:Tab /:<CR>:Tab /=<CR>:Tab /\S\+; <CR>
vnoremap <C-g>,1 :Tab /,<CR>:Tab /:<CR>:Tab /=<CR>:Tab /\S\+; <CR>

" ---------------
" TCommenter
" ---------------
nmap <C-c> <C-g>ccj
vmap <C-c> <C-g>c
" Comment paragraph
nmap <leader>cp gcip

"****************************************
" Functions
"****************************************
" TODO I forget what this does
augroup BWCCreateDir
  au!
  autocmd BufWritePre * if expand("<afile>")!~#'^\w\+:/' && !isdirectory(expand("%:h")) | execute "silent! !mkdir -p ".shellescape(expand('%:h'),  1) | redraw! | endif
augroup END

" Fix Trailing White Space
command! FixTrailingWhiteSpace :%s/\s\+$//e

" ---------------
" Folds
" ---------------
" Save and restore folds automatically
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent loadview
if has("folding")
  set foldtext=MyFoldText()
  function! MyFoldText()
    " for now, just don't try if version isn't 7 or higher
    if v:version < 701
      return foldtext()
    endif
    " clear fold from fillchars to set it up the way we want later
    let &l:fillchars = substitute(&l:fillchars,',\?fold:.','','gi')
    let l:numwidth = (v:version < 701 ? 8 : &numberwidth)
    if &fdm=='diff'
      let l:linetext=''
      let l:foldtext='---------- '.(v:foldend-v:foldstart+1).' lines the same ----------'
      let l:align = winwidth(0)-&foldcolumn-(&nu ? Max(strlen(line('$'))+1, l:numwidth) : 0)
      let l:align = (l:align / 2) + (strlen(l:foldtext)/2)
      " note trailing space on next line
      setlocal fillchars+=fold:\ 
    elseif !exists('b:foldpat') || b:foldpat==0
      let l:foldtext = ' '.(v:foldend-v:foldstart).' lines folded'.v:folddashes.'|'
      let l:endofline = (&textwidth>0 ? &textwidth : 80)
      let l:linetext = strpart(getline(v:foldstart),0,l:endofline-strlen(l:foldtext))
      let l:align = l:endofline-strlen(l:linetext)
      setlocal fillchars+=fold:-
    elseif b:foldpat==1
      let l:align = winwidth(0)-&foldcolumn-(&nu ? Max(strlen(line('$'))+1, l:numwidth) : 0)
      let l:foldtext = ' '.v:folddashes
      let l:linetext = substitute(getline(v:foldstart),'\s\+$','','')
      let l:linetext .= ' ---'.(v:foldend-v:foldstart-1).' lines--- '
      let l:linetext .= substitute(getline(v:foldend),'^\s\+','','')
      let l:linetext = strpart(l:linetext,0,l:align-strlen(l:foldtext))
      let l:align -= strlen(l:linetext)
      setlocal fillchars+=fold:-
    endif
    return printf('%s%*s', l:linetext, l:align, l:foldtext)
  endfunction
endif

"Improve appearance of folded text
function! NeatFoldText()
  let line = ' ' . substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{{\d*\s*', '', 'g') . ' '
  let lines_count = v:foldend - v:foldstart + 1
  let lines_count_text = '| ' . printf("%10s", lines_count . ' lines') . ' |'
  let foldchar = '·'
  let foldtextstart = strpart('+' . repeat(foldchar, v:foldlevel*2) . line, 0, (winwidth(0)*2)/3)
  let foldtextend = lines_count_text . repeat(foldchar, 8)
  let length = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g'))
  return foldtextstart . repeat(foldchar, winwidth(0)-length) . foldtextend
endfunction
set foldtext=NeatFoldText()

"No annoying warnings for sudo saves and read only saves
let s:IgnoreChange=0
autocmd! FileChangedRO * nested
    \ let s:IgnoreChange=1 | call system("p4 edit " . expand("%")) | set noreadonly
autocmd! FileChangedShell *
    \ if 1 == s:IgnoreChange | let v:fcs_choice="" | let s:IgnoreChange=0 | else |
    \   let v:fcs_choice="ask" |
    \ endif
"Relative line numbers in normal mode, absolute in insert mode
au InsertEnter * :set number
au InsertLeave * :set relativenumber
"TODO don't work
"Switch to absolute line numbers when focus is lost
au FocusLost * :set number
au FocusGained * :set relativenumber

" Backup
au BufWritePre * let &bex = '-' . strftime("%Y%b%d%X") . '~' 

" Returns the wordcount of the document
function! WordCount()
  let s:old_status = v:statusmsg
  let position = getpos(".")
  exe "silent normal g\<c-g>"
  if strlen(v:statusmsg) > 22
    let s:word_count = str2nr(split(v:statusmsg)[11])
    let v:statusmsg = s:old_status
    call setpos('.', position)
    return s:word_count
  else
    return 0
  endif
endfunction

"******************************
"* Unused/Broken
"******************************

" Incremental backups
" augroup backup
    " autocmd!
    " autocmd BufWritePre,FileWritePre * let &l:backupext = '~' . strftime('%F') . '~'
" augroup END
" ---------------
" Quickfix
" ---------------
" au FileType qf
"                 \ if &buftype == "quickfix" |
"                 \     setlocal statusline=%2*%-3.3n%0* |
"                 \     setlocal statusline+=\ \[Compiler\ Messages\] |
"                 \     setlocal statusline+=%=%2*\ %<%P |
"                 \ endif
"            autocmd QuickFixCmdPost make
"             \ let g:make_total_time=localtime() - g:make_start_time |
"             \ echo printf("Time taken: %dm%2.2ds", g:make_total_time / 60,
"             \     g:make_total_time % 60)

" autocmd QuickFixCmdPre *
"             \ let g:old_titlestring=&titlestring |
"             \ let &titlestring="[ " . expand("<amatch>") . " ] " . &titlestring |
"             \ redraw

" autocmd QuickFixCmdPost *
"             \ let &titlestring=g:old_titlestring
" ---------------
" txt
" ---------------
" Spellchecking
" autocmd BufNewFile,BufRead *.txt,*.html,README set spell

" " Autosave
" au BufRead,BufNewFile * let b:start_time=localtime()
" au CursorHold * call UpdateFile()
" " only write if needed and update the start time after the save
" function! UpdateFile()
"   if ((localtime() - b:start_time) >= 60)
"     update
"     let b:start_time=localtime()
"   " else
"     " echo "Only " . (localtime() - b:start_time) . " seconds have elapsed so far."
"   endif
" endfunction
" "Reset the start time explicitly after each save.
" au BufWritePre * let b:start_time=localtime()

"******************************
"* Potential Packages
"******************************

" Smart search/replace
" NeoBundle 'tpope/vim-abolish'
" Autoclose brackets
" NeoBundle 'Raimondi/delimitMate'
" Cycle through yanks
" NeoBundle 'maxbrunsfeld/vim-yankstack'

"----------------------------------------
" savevers
"----------------------------------------
" let savevers_types='*' 
" let savevers_max=9999 
" let savevers_purge=1 
" let savevers_dirs=&backupdir 
" set patchmode=.BAK
"----------------------------------------
" Rainbow Parens
"----------------------------------------
" let g:rbpt_colorpairs = [
"     \ ['brown',       'RoyalBlue3'],
"     \ ['Darkblue',    'SeaGreen3'],
"     \ ['darkgray',    'DarkOrchid3'],
"     \ ['darkgreen',   'firebrick3'],
"     \ ['darkcyan',    'RoyalBlue3'],
"     \ ['darkred',     'SeaGreen3'],
"     \ ['darkmagenta', 'DarkOrchid3']
"     \ ]
" cal rainbow_parentheses#activate()
" au Syntax * RainbowParenthesesLoadRound
" au Syntax * RainbowParenthesesLoadSquare
" au Syntax * RainbowParenthesesLoadBraces
" au Syntax * RainbowParenthesesLoadChevrons

"----------------------------------------
" Ctags
"----------------------------------------
" function! GenerateTagsFile()
"   if (!filereadable("tags"))
"     exec ":!start /min ctags -R --c++-kinds=+p --fields=+iaS --extra=+q --sort=foldcase ."
"   endif
" endfunction
" 
" " Always change to directory of the buffer currently in focus.
" autocmd! bufenter *.* :cd %:p:h
" autocmd! bufread  *.* :cd %:p:h
" 
" " Generate tags on opening an existing file.
" autocmd! bufreadpost *.cpp :call GenerateTagsFile()
" autocmd! bufreadpost *.c   :call GenerateTagsFile()
" autocmd! bufreadpost *.h   :call GenerateTagsFile()
" 
" " Generate tags on save. Note that this regenerates tags for all files in current folder.
" autocmd! bufwritepost *.cpp :call GenerateTagsFile()
" autocmd! bufwritepost *.c   :call GenerateTagsFile()
" autocmd! bufwritepost *.h   :call GenerateTagsFile()

"----------------------------------------
" Tagbar
"----------------------------------------
" let g:tagbar_left = 1
" let g:tagbar_autofocus = 1
" " g:tagbar_compact = 0 "Hide the help
" "Switch tagbar when buffer is switched

" ---------------
" DelimitMate
" ---------------
"CUSTOM
" let delimitMate_expand_cr = 1
" let delimitMate_autoclose = 1
" let delimitMate_balance_matchpairs = 1
" let delimitMate_expand_cr = 1
" " If using html auto complete (complete closing tag)
" au FileType xml,html,xhtml let delimitMate_matchpairs = "(:),[:],{:}"
"

"----------------------------------------
" Yankstack
"----------------------------------------
" nmap <leader>p <Plug>yankstack_substitute_older_paste
" nmap <leader>P <Plug>yankstack_substitute_newer_paste

" NeoBundle 'vim-scripts/savevers.vim' " Automated backup
"******************************
"* Temporary
"******************************
