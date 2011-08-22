"General {{{
"---------------------------------------------------------------------------------
call pathogen#runtime_append_all_bundles()
silent! call pathogen#helptags()

filetype plugin indent on

set nocompatible " Just in case
set backspace=indent,eol,start

syntax on
set number
set relativenumber " Experimental
set ruler

set scrolloff=3
set scroll=15

set ttimeoutlen=50 " Make Esc work faster

" Identation
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" Encoding
if exists("+encoding")
    set encoding=utf-8
endif

" Folding
set foldmethod=marker

" Appearance
if has("gui_running")
    " Scrollbars and toolbars are so 2011. Remove them!
    set guioptions -=T
    set guioptions -=L
    set guioptions -=r

    " Set color scheme and font
    color solarized
    set background=light
    set guifont=Monaco:h12

    " Maximize (lolmac)
    set lines=55
else
    if &term == "xterm-256color"
        let &t_Co=256
    else
        let &t_Co=16
    endif

    color yannis

    " Enable the mouse
    set mouse=a
endif

" Always show a status line
set laststatus=2

set report=0
set showcmd

" Don't jump to the start of line with CTRL+U / CTRL+D
set nostartofline

" Zsh-like command line completion
set wildmenu

set autoindent
set nowrap

" Search
set ignorecase smartcase
set incsearch
set nohlsearch

set directory=/tmp

command! -bar -nargs=0 SudoW   :setl nomod|silent exe 'write !sudo tee % >/dev/null'|let &mod = v:shell_error
command! -bar -nargs=* -bang W :write<bang> <args>
command! -bar -nargs=* -bang Q :quit<bang> <args>

" Terminal-consistent shortcut keys for command line
cnoremap <C-A> <Home>
cnoremap <C-K> <C-\>estrpart(getcmdline(), 0, getcmdpos() - 1)<CR>

" Window navigation
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

" Not interested
nnoremap K <nop>

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

" }}}
" File Types {{{
"---------------------------------------------------------------------------------

autocmd Filetype gitcommit set textwidth=68 spell
autocmd Filetype ruby      set textwidth=86 tabstop=2 softtabstop=2 shiftwidth=2
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
map Qi :silent :call RefactorInlineVariable()<cr>

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
let g:CommandTMaxHeight = 5

" }}}
" Leader key mappings {{{
"---------------------------------------------------------------------------------
" <space>rb : Open ruby documentation for the word under cursor
" <space>rr : Open rails documentation for the word under cursor
"
" <space>n  : Rename current file
" <space>v  : Open .vimrc
"
" <space>h  : Show syntax highlighting group (useful when editing the
"             colorscheme)
"
" <space>s  : Remove trailing whitespaces and empty lines from the EOF
"
" <space>cc : Save, compile and run (if the compilation was successful) C file.
" <space>cp : Save, compile and run (if the compilation was successful) C++ file.
"
" <space>f  : Open Command-T
" <space>om : Open Command-T with the directory set to models
" <space>oc : Open Command-T with the directory set to controllers
" <space>ov : Open Command-T with the directory set to views
" <space>os : Open Command-T with the directory set to spec
" <space>ol : Open Command-T with the directory set to lib
"---------------------------------------------------------------------------------

" Set mapleader (to <space>) for custom commands
let mapleader = ' '

" Open ruby and ruby on rails documentation
" (from https://github.com/technicalpickles/pickled-vim/blob/master/home/.vimrc)

let g:browser = 'open '

" Open the Rails ApiDock page for the word under cursor, using the 'open'
" command
function! OpenRailsDoc(keyword)
    let url = 'http://apidock.com/rails/'.a:keyword
    exec '!'.g:browser.' '.url
endfunction

" Open the Ruby ApiDock page for the word under cursor, using the 'open'
" command
function! OpenRubyDoc(keyword)
    let url = 'http://apidock.com/ruby/'.a:keyword
    exec '!'.g:browser.' '.url
endfunction

noremap <leader>rb :call OpenRubyDoc(expand('<cword>'))<cr>
noremap <leader>rr :call OpenRailsDoc(expand('<cword>'))<cr>

" Command to rename current file
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
map <leader>cc :w<cr>:!gcc % && ./a.out<cr>
map <leader>cp :w<cr>:!g++ % && ./a.out<cr>

" Command-T shortcuts
map <leader>f :CommandTFlush<cr>\|:CommandT<cr>
map <leader>ov :CommandTFlush<cr>\|:CommandT app/views<cr>
map <leader>oc :CommandTFlush<cr>\|:CommandT app/controllers<cr>
map <leader>om :CommandTFlush<cr>\|:CommandT app/models<cr>
map <leader>os :CommandTFlush<cr>\|:CommandT spec<cr>
map <leader>ol :CommandTFlush<cr>\|:CommandT lib<cr>
" }}}
