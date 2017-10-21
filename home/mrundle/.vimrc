" .vimrc

:color desert

" Remap the escape key
:imap jk <Esc>

" Auto complete
" :help 'complete'
:imap <Tab><Tab> <C-P>
set complete=.,w,b,u,t,i,d,]
set completeopt=longest,menuone

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

"set formatoptions=cnt1
set textwidth=80
set wrapmargin=0
