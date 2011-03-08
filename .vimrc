set makeprg=rake
filetype on  " Automatically detect file types.
set nocompatible  " We don't want vi compatibility.
syntax enable
filetype plugin indent on
au BufNewFile,BufRead *.t2t set ft=txt2tags
set ts=2  " Tabs are 2 spaces
set bs=2  " Backspace over everything in insert mode
set shiftwidth=2  " Tabs under smart indent
set autoindent
set smarttab
set expandtab
set spelllang=en,de
