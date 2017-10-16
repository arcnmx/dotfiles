set nocompatible
set backspace=indent,eol,start

set nobackup
set history=500
set ruler
set showcmd
set incsearch

set viminfo='100000,<100000,s1000,h " Get rid of line copy limit
silent ! [ -d $HOME/.vim/swap ] || mkdir $HOME/.vim/swap
set directory=$HOME/.vim/swap//

set tabstop=4
set softtabstop=4
set shiftwidth=4
set smarttab
set number

command Spaces set expandtab
command Tabs set noexpandtab

set hidden " allow buffer switching without saving

let clang_complete_auto=1
let clang_use_library=1
let clang_library_path="/usr/lib"
let clang_complete_copen=1
let clang_complete_periodic_quickfix=1
let clang_exec="/usr/bin/clang++"
let rust_recommended_style=0
set completeopt=menuone,longest
set timeoutlen=100
au BufRead,BufNewFile *.kt setlocal filetype=kotlin
au BufRead,BufNewFile *.as setlocal filetype=javascript
au BufRead,BufNewFile *.rs compiler cargo
let g:cargo_makeprg_params="check --color always"
let g:vim_markdown_folding_disabled=1
let g:solarized_termtrans=1
set background=dark " dark | light "
set cursorline
set colorcolumn=80
set shortmess+=I
let g:notmuch_folders = [
\ ['new', 'tag:unread and tag:inbox'],
\ ['inbox', 'tag:inbox'],
\ ['unread', 'tag:unread and not tag:inbox'],
\ ['all', 'path:**'],
\ ['work', 'tag:work'],
\ ['junk', 'tag:junk'],
\ ]
let g:notmuch_folders_count_threads=0
let g:notmuch_date_format='%y-%m-%d %H:%M'
let g:notmuch_datetime_format='%y-%m-%d %H:%M'
let g:notmuch_custom_search_maps={
\ 'x': 'kill_this_buffer()',
\ 'd': 'search_tag("+deleted -inbox -unread")',
\ }
let g:notmuch_custom_show_maps={
\ 'x': 'kill_this_buffer()',
\ 'd': 'search_tag("+deleted -inbox -unread")',
\ }
let g:notmuch_save_sent_locally=1
let g:notmuch_save_sent_mailbox='sent'
let g:notmuch_sendmail_method='sendmail'
let g:notmuch_sendmail_param={
\ 'location': '/usr/bin/msmtp',
\}


" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

nnoremap q <Nop>

syntax on
set hlsearch

filetype off
call vundle#begin()
Plugin 'tpope/vim-dispatch'
Plugin 'cespare/vim-toml'
Plugin 'rust-lang/rust.vim'
Plugin 'imain/notmuch-vim'
Plugin 'altercation/vim-colors-solarized'
call vundle#end()

filetype plugin indent on

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
au!

" For all text files set 'textwidth' to 78 characters.
autocmd FileType text setlocal textwidth=78

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
autocmd BufReadPost *
\ if line("'\"") > 1 && line("'\"") <= line("$") |
\   exe "normal! g`\"" |
\ endif

augroup END

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

colorscheme solarized
" call togglebg#map("<F5>")

" Avoid E173
if argc() > 1
  silent blast " load last buffer
  silent bfirst " switch back to the first
endif
