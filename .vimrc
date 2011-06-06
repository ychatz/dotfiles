call pathogen#runtime_append_all_bundles()
silent! call pathogen#helptags()

filetype plugin indent on

set nocompatible "just in case
set backspace=indent,eol,start

syntax on
set number
set ruler

set scrolloff=3
set scroll=15

" Identation
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

autocmd FileType ruby setlocal shiftwidth=2 tabstop=2 softtabstop=2

" Encoding
if exists("+encoding")
    set encoding=utf-8
endif

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
    let &t_Co=16
    color yannis

    " Enable the mouse
    set mouse=a
endif

" Always show a status line
set laststatus=2

set report=0
set showcmd

set autoindent
set nowrap

" Search
set ignorecase smartcase

set directory=/tmp

" No idea why this is here. I don't use Esc anyway.
map <F1> <Esc>
imap <F1> <Esc>

command! W :w
command! Q :q

" Terminal-consistent shortcut keys for command line
cnoremap <C-A> <Home>
cnoremap <C-K> <C-\>estrpart(getcmdline(), 0, getcmdpos() - 1)<CR>

" Window navigation
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

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

"---------------------------------------------------------------------------------
" Plugin Configuration
"---------------------------------------------------------------------------------

" Define Rroutes, RVroutes etc.
autocmd User Rails Rnavcommand routes config/ -suffix= -default=routes.rb
" Define Rpublic
autocmd User Rails Rnavcommand public public/ -suffix= -default=index.html -glob=**/*

"---------------------------------------------------------------------------------
" Custom commands mapped to leader key
"---------------------------------------------------------------------------------
"
" <space>rb : Open ruby documentation for the word under cursor
" <space>rr : Open rails documentation for the word under cursor
"
" <space>n  : Rename current file
" <space>v  : Open .vimrc
"
" <space>h  : Show syntax highlighting group (useful when editing the
"             colorscheme)
"
" <space>s  : Remove trailing whitespaces and empty lines at the EOF
"
" <space>cc : Save, compile and run (if the compilation was successful) C file.
" <space>cp : Save, compile and run (if the compilation was successful) C++ file.
"
" <space>t  : Run rspec tests for current file
" <space>T  : Run rspec tests for all files
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

" Run tests
map <leader>t :w<cr>:!rspec %<cr>
map <leader>T :w<cr>:!rspec spec<cr>
