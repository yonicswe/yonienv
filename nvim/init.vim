
" nvim config file cloned from : https://github.com/neuralnine/config-files

let g:mapleader = ","

:set rtp+=/home/ycohen/share/tmp/fzf/
nmap <C-P> :FZF<cr>

source ~/.config/nvim/pluggins.vim
source ~/.config/nvim/settings.vim
source ~/.config/nvim/mappings.vim

set encoding=UTF-8

:set completeopt-=preview " For No Previews

:colorscheme jellybeans








function! Insert_indent_symbol (number)
   let v=a:number
   let s='r! sed -n '.v.'p ~/.vim/vim_indent_symbols.txt'
"    echom s
   exec s
endfunc

function! Insert_vim_symbol (number)
   let v=a:number
   let s='r! sed -n '.v.'p ~/.vim/vim_symbols.txt'
"    echom s
   exec s
endfunc

map <leader>ll :call Insert_vim_symbol(1)<CR>
map <leader>l1 :call Insert_indent_symbol(1)<CR>
map <leader>l2 :call Insert_indent_symbol(2)<CR>
map <leader>l3 :call Insert_indent_symbol(3)<CR>
map <leader>l4 :call Insert_indent_symbol(4)<CR>
map <leader>l5 :call Insert_indent_symbol(5)<CR>
com! -nargs=1 I call Insert_indent_symbol(<f-args>)

"
" ============= vimdiff ========================
"       _            _  _   __   __
" __ __(_) _ __   __| |(_) / _| / _|
" \ V /| || '  \ / _` || ||  _||  _|
" \_/ |_||_|_|_|\__,_||_||_|  |_|
"
"
" to ignore white space :set diffopt+=iwhite
" :diffupdate to rescan diffs
if &diff
    colorscheme molokai
"     colorscheme candycode
    map <C-Down> ]c
    map <C-Up>   [c
    map <C-Right> :wincmd w<cr>
    map <C-Left>  :wincmd w<cr>
"   map <C-i> :set diffopt=iwhite<cr>
"   map <C-i><C-i> :set diffopt=filler<cr>

    map <C-u> :diffupdate

    map <C-i> :call IwhiteToggle()<CR>
    function! IwhiteToggle()
      if &diffopt =~ 'iwhite'
        set diffopt-=iwhite
      else
        set diffopt+=iwhite
      endif
    endfunction
endif

fun! ShowFuncName()
  let lnum = line(".")
  let col = col(".")
  echohl ModeMsg
  echo getline(search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bW'))
  echohl None
  call search("\\%" . lnum . "l" . "\\%" . col . "c")
endfun
map f :call ShowFuncName() <CR>
" can also do :normal [[<cr>

silent! cs a .
packadd termdebug
