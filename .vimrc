"General {{{
"---------------------------------------------------------------------------------
call pathogen#runtime_append_all_bundles()
silent! call pathogen#helptags()

filetype plugin indent on

set nocompatible " Just in case
set backspace=indent,eol,start

syntax on
set nonumber relativenumber " Experimental
set ruler

set scrolloff=3
set scroll=15

set ttimeoutlen=50 " Make Esc work faster

" Indentation
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent

" Encoding
if exists("+encoding")
  set encoding=utf-8
endif

" Folding
set foldmethod=marker

" Interface
if has("gui_running")
  " Scrollbars and toolbars are so 2012. Remove them!
  set guioptions -=T
  set guioptions -=L
  set guioptions -=r

  " Set color scheme and font
  color yannis
  set background=light
  set guifont=Monaco:h13

  " Maximize (lolmac)
  set lines=55
else
  if &term == "xterm-256color"
    let &t_Co=256
  else
    let &t_Co=16
  endif

  color yannis256

  " Enable the mouse
  set mouse=a
endif

" Highlight the screen line of the cursor
set cursorline
" Always show a status line
set laststatus=2
" Always report the number of lines changed
set report=0
"Show partial command in the bottom-right corner
set showcmd

" Don't jump to the start of line with CTRL+U / CTRL+D
set nostartofline

" Zsh-like command line completion
set wildmenu
" Don't wrap text by default
set nowrap

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch

set directory=/tmp

" set list listchars=trail:·

" Terminal-consistent shortcut keys for command line
cnoremap <C-A> <Home>
cnoremap <C-K> <C-\>estrpart(getcmdline(), 0, getcmdpos() - 1)<CR>
cnoremap <C-O> <CR>

" Window navigation
set winminheight=0
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

" Fix motions for wrapped lines
nnoremap j gj
nnoremap k gk

" Remap the tab key to do autocompletion or indentation depending on the
" context (from http://www.vim.org/tips/tip.php?tip_id=102)
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-n>"
  endif
endfunction
inoremap <Tab> <C-R>=InsertTabWrapper()<CR>
inoremap <S-Tab> <C-P>

" Search for visually selected text, forwards or backwards (from
" http://vim.wikia.com/wiki/Search_for_visually_selected_text)
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

" }}}
" File Types / Autocommands {{{
"---------------------------------------------------------------------------------

autocmd Filetype gitcommit set expandtab textwidth=68 spell
autocmd Filetype ruby      set expandtab textwidth=80 tabstop=2 softtabstop=2 shiftwidth=2 formatoptions+=c path=.,,
autocmd FileType vim       set expandtab shiftwidth=2 softtabstop=2 keywordprg=:help
autocmd FileType c         set softtabstop=4 makeprg=gcc\ -O2
autocmd FileType cpp       set makeprg=g++

" autocmd WinEnter *         if &buftype != 'quickfix' | wincmd _ | endif

" Don't highlight the cursor line on the quickfix window
autocmd BufReadPost quickfix setlocal nocursorline

" Maximize the window after entering it, be sure to keep the quickfix window
" at the specified height.
" From http://vim.wikia.com/wiki/Always_keep_quickfix_window_at_specified_height
au WinEnter * call MaximizeAndResizeQuickfix(10)

" Maximize current window and set the quickfix window to the specified height.
function MaximizeAndResizeQuickfix(quickfixHeight)
  " Redraw after executing the function.
  set lazyredraw
  " Ignore WinEnter events for now.
  set ei=WinEnter
  " Maximize current window.
  wincmd _
  " If the current window is the quickfix window
  if (getbufvar(winbufnr(winnr()), "&buftype") == "quickfix")
    " Maximize previous window, and resize the quickfix window to the
    " specified height.
    wincmd p
    resize
    wincmd p
    exe "resize " . a:quickfixHeight
  else
    " Current window isn't the quickfix window, loop over all windows to
    " find it (if it exists...)
    let i = 1
    let currBufNr = winbufnr(i)
    while (currBufNr != -1)
      " If the buffer in window i is the quickfix buffer.
      if (getbufvar(currBufNr, "&buftype") == "quickfix")
        " Go to the quickfix window, set height to quickfixHeight, and jump to
        " the previous window.
        exe i . "wincmd w"
        exe "resize " . a:quickfixHeight
        wincmd p
        break
      endif
      let i = i + 1
      let currBufNr = winbufnr(i)
    endwhile
  endif
  set ei-=WinEnter
  set nolazyredraw
endfunction
" }}}
" Ruby refactoring {{{
"---------------------------------------------------------------------------------
" Who uses ex-mode anyway?
"
"   Qi : Inline variable
" v_Qm : Extract method
"---------------------------------------------------------------------------------

function! RefactorInlineVariable()
  " Go to the beginning of the line
  normal _
  " Find the next occurence of variable
  normal *
  " Go back
  normal ''
  " Copy the variable name into register v
  normal "vde
  " Delete the = and the two spaces
  normal 3x
  " Copy the variable expression into register y
  normal "cD
  " Delete the rest of the line
  normal dd
  " Go back again to the next occurence
  normal ''
  " Replace all of the variable's occurences in this line
  exec ':.s:\<' . @v . '\>:' . @c . ':gI'
endfunction
map Qi :silent :call RefactorInlineVariable()<cr>
map QI :silent :call RefactorInlineVariable()<cr>

function! RefactorExtractMethod() range
  let method_name = input('(Extract method) New method name: ')
  " Go to the last selected line
  exec "normal! " . a:lastline . "G"
  " Write the call to the new method below it
  exec "normal! o" . method_name
  " Go to the beginning of the current method
  normal [m
  " Insert the body of the new method above it
  exec "normal! Odef " . method_name . "\<cr>end\<cr>"
  " The body is 3 lines long, so everything moved down by 3 lines
  let firstline = a:firstline + 3
  let lastline  = a:lastline + 3
  " Get the current line number
  let curline = getpos('.')[1]
  " Move the selected text inside the new method body
  exec ":" . firstline . "," . lastline . "m " . (curline-2)
endfunction
vnoremap Qm :call RefactorExtractMethod()<cr>
vnoremap QM :call RefactorExtractMethod()<cr>

" }}}
" Plugin Configuration {{{
"---------------------------------------------------------------------------------

" Define Rroutes, RVroutes etc.
autocmd User Rails Rnavcommand routes config/ -suffix= -default=routes.rb
" Define Rpublic
autocmd User Rails Rnavcommand public public/ -suffix= -default=index.html -glob=**/*

" Show dotfiles in CommandT
let g:CommandTAlwaysShowDotFiles = 1
" Ctrl-W opens current file in split window
let g:CommandTAcceptSelectionSplitMap = '<C-w>'
" No more than 5 lines
let g:CommandTMaxHeight = 7
" Ignore certain filetypes
set wildignore=*.o,*.out

" }}}
" Leader key mappings {{{
"---------------------------------------------------------------------------------

" Set mapleader (to <space>) for custom commands
let mapleader = ' '

"   n         : Rename current file
"   v         : Open .vimrc
"   h         : Show syntax highlighting group (useful when editing the scheme)
"   H         : Open a vertical window and edit the current colorscheme
"   s         : Remove trailing whitespaces and empty lines from the EOF
"   c         : Save, compile and run (if the compilation was successful)
"   f         : Open Command-T
"   t         : Open Command-T for tags
"   om        : Open Command-T with the directory set to models
"   oc        : Open Command-T with the directory set to controllers
"   ov        : Open Command-T with the directory set to views
"   os        : Open Command-T with the directory set to spec
"   ol        : Open Command-T with the directory set to lib
"   <space>   : Edit the alternate file
"---------------------------------------------------------------------------------

function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'))
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction
map <leader>n :call RenameFile()<cr>

map <leader>h :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
            \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
            \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<cr>

map<leader>H :exec "vsplit ~/.vim/colors/" . g:colors_name . ".vim"<cr>

" Clean up file
function! StripWhitespace ()
  " Remove trailing whitespaces
  exec ':%s/ *$/'
  " Remove empty lines at the EOF
  normal G
  while getline('.') == ''
    normal dd
  endwhile
  normal ``
endfunction
map <leader>s :call StripWhitespace ()<cr>

" Open .vimrc
map <leader>v :e $MYVIMRC<cr>

" Save, compile and run files
function! CompileAndRun()
  write
  silent! make %
  redraw!
  cwindow
  if len(getqflist()) == 0
    exec '!time ./a.out'
  endif
endfunction
map <leader>c :call CompileAndRun()<cr>

" Command-T shortcuts
map <leader>t :CommandTTag<cr>
map <leader>f :CommandTFlush<cr>\|:CommandT<cr>
map <leader>ov :CommandTFlush<cr>\|:CommandT app/views<cr>
map <leader>oc :CommandTFlush<cr>\|:CommandT app/controllers<cr>
map <leader>om :CommandTFlush<cr>\|:CommandT app/models<cr>
map <leader>os :CommandTFlush<cr>\|:CommandT spec<cr>
map <leader>ol :CommandTFlush<cr>\|:CommandT lib<cr>

map <leader><leader> <C-^>
" }}}
" Custom command definitions {{{
"---------------------------------------------------------------------------------

command! -bar -nargs=0 SudoW   :setl nomod|silent exe 'write !sudo tee % >/dev/null'|let &mod = v:shell_error
command! -bar -nargs=* -bang W :write<bang> <args>
command! -bar -nargs=* -bang Q :quit<bang> <args>

" Turn off syntax highlighting
command! C nohlsearch

" Align the first 'count' columns separated by one or more spaces
function! AlignColumns(count) range
  let lnum = 1
  let str = ':'
  while lnum <= a:count
    let str = 'l' . str
    let lnum = lnum + 1
  endwhile
  exec ":AlignCtrl " . str
  " Create a random string
  redir @s
  ruby require 'digest/md5'; printf Digest::MD5.hexdigest(rand(50000).to_s)
  redir END
  let @s = strpart(@s, 1, strlen(@s) - 1)
  " Replace spaces with it
  silent exec ":" . a:firstline . "," . a:lastline . "s/\\s\\+/" . @s . "/g"
  " Align columns separated by that string
  exec ":" . a:firstline . "," . a:lastline . "Align " . @s
  " Bring back the spaces
  silent exec ":" . a:firstline . "," . a:lastline . "s/" . @s . "/ /g"
  " Clear the search pattern register
  exec ":C"
endfunction

command! -nargs=* -range Al <line1>,<line2>call AlignColumns(<args>)
"}}}
" Language maps {{{
"---------------------------------------------------------------------------------

" Make commands work when keyboard sends greek characters
if &encoding == "utf-8"
  set langmap=ΑA,ΒB,ΨC,ΔD,ΕE,ΦF,ΓG,ΗH,ΙI,ΞJ,ΚK,ΛL,ΜM,ΝN,ΟO,ΠP,QQ,ΡR,ΣS,ΤT,ΘU,ΩV,WW,ΧX,ΥY,ΖZ,αa,βb,ψc,δd,εe,φf,γg,ηh,ιi,ξj,κk,λl,μm,νn,οo,πp,qq,ρr,σs,τt,θu,ωv,ςw,χx,υy,ζz,¨:
endif
"}}}
