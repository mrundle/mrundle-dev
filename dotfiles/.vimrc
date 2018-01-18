" .vimrc

:color desert

syntax on
filetype plugin indent on

" Auto complete (hit Tab+Tab to see completions)
" :help 'complete'
:imap <Tab><Tab> <C-P>
set complete=.,w,b,u,t,i,d,]
set completeopt=longest,menuone

" Remap the escape key
:imap jk <Esc>

" show existing tab with 4 spaces width
set tabstop=4    " show existing tabs w/ 4 spaces
set shiftwidth=4 " when indenting with '>', use 4 spaces width
set expandtab    " On pressing tab, insert 4 spaces

" show line numbers
set number

" highlight the 81st column
:2mat ErrorMsg '\%81v.'

" bigger clipboard
set viminfo='20,<1000

" use "]s" to go to next misspelled word
" use "z=" on misspelled word to get recommendations
" use "zg" on misspelled word to mark bad, "zw" to re-mark bad
set spell spelllang=en_us
hi clear SpellBad
hi SpellBad cterm=bold,undercurl

:highlight ExtraWhitespace ctermbg=red
:match ExtraWhitespace /\s\+$/

"set formatoptions=cnt1
set textwidth=80
set wrapmargin=0

" ALE
" needs vim8
" mkdir -p ~/.vim/pack/git-plugins/start
" git clone https://github.com/w0rp/ale.git ~/.vim/pack/git-plugins/start/ale
:let g:ale_c_gcc_options = '-std=gnu99
                          \ -Wall
                          \ -Werror
                          \ -Wextra
                          \ -Wno-unused-function
                          \ -Wno-unused-parameter
                          \ -Wframe-larger-than=32768
                          \ -Wstrict-overflow=5
                          \ -fno-strict-aliasing
                          \ -fno-delete-null-pointer-checks'

" vim8
set backspace=indent,eol,start

" more natural window movement (ctr+j instead of ctrl+W+j)
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Unicode digraphs courtesy of gooddan@
" Japanese quotation marks
"     <C-k>[[ = ⌈
"     <C-k>]] = ⌋
" Fullwidth asterisk
"     <C-k>88 = ＊
dig [[ 8968 ]] 8971 88 65290

" Load all plugins now
" Plugins need to be added to runtimepath before helptags can be generated
"packloadall
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored
"silent! helptags ALL
