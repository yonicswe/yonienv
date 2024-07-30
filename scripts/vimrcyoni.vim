set mouse=a
set hlsearch
set nowrapscan
set nu
map <S-s> :w<CR>
map <C-w><C-w> :qa!
set ruler
set wildmenu
set laststatus=2
set statusline=%<%F\ %h%m%r%=%-14.(\[%l:%L\]\[%v\]%)\ %P
colorscheme darkblue
imap jk <esc>
set mouse=a
noremap <S-l> :let @/ = ""<CR>
vmap / y/<C-R>"<CR>
map <leader>m :source ~/.vimrc<cr>:edit<cr>
