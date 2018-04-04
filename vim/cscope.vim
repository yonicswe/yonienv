set cscopequickfix=s-,c-,d-,i-,t-,e-

" nmap <C-Space>s :cs find s <C-R>=expand("<cword>")<CR><CR>
" nmap <C-Space>g :cs find g <C-R>=expand("<cword>")<CR><CR>
" nmap <C-Space>c :cs find c <C-R>=expand("<cword>")<CR><CR>
" nmap <C-Space>t :cs find t <C-R>=expand("<cword>")<CR><CR>
" nmap <C-Space>e :cs find e <C-R>=expand("<cword>")<CR><CR>
" nmap <C-Space>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
" nmap <C-Space>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
" nmap <C-Space>d :cs find d <C-R>=expand("<cword>")<CR><CR>

nmap ,fs :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap ,fg :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap ,fc :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap ,ft :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap ,fe :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap ,ff :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap ,fi :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap ,fd :cs find d <C-R>=expand("<cword>")<CR><CR>
"view the list of matches with:
":cw[indow]

" run cscope -Rb on your project.
