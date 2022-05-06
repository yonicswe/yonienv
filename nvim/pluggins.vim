
" Using vim-plug
" 1. clone vim-plug from : https://github.com/junegunn/vim-plug
" 2. sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
"
" --- Just Some Notes ---
" :PlugClean :PlugInstall :UpdateRemotePlugins

call plug#begin()

" -------- ide plugs -------------
Plug 'preservim/nerdcommenter'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
Plug 'https://github.com/preservim/nerdtree' " NerdTree
" Plug 'https://github.com/tpope/vim-commentary' " For Commenting gcc & gc
Plug 'https://github.com/preservim/tagbar' " Tagbar for code navigation

Plug 'http://github.com/tpope/vim-surround' " Surrounding ysw)
" Plug 'https://github.com/terryma/vim-multiple-cursors' " CTRL + N for multiple cursors

" required for telescope : plenary, treesitter and ripgrep.
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'https://github.com/BurntSushi/ripgrep'
Plug 'nvim-telescope/telescope.nvim'

" -------- debug tools plugs -----------
" Plug 'voldikss/vim-floaterm'
" Plug 'https://github.com/tc50cal/vim-terminal' " Vim Terminal

" -------- office plugs ---------------
Plug 'vimwiki/vimwiki'
" Plug 'tbaej/taskwiki'
" Plug 'https://github.com/tools-life/taskwiki'
Plug 'mhinz/vim-startify'

" -------- visuality plugs ---------
Plug 'https://github.com/vim-airline/vim-airline' " Status bar
Plug 'https://github.com/ap/vim-css-color' " CSS Color Preview
Plug 'https://github.com/rafi/awesome-vim-colorschemes' " Retro Scheme
Plug 'https://github.com/ryanoasis/vim-devicons' " Developer Icons
Plug 'kyazdani42/nvim-web-devicons'
" Plug 'itchyny/lightline.vim'

Plug 'romgrk/barbar.nvim' " Tabs manipulation
 
call plug#end()

" ============ nerdtree mappings/settings ===================
nnoremap <C-f> :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTreeToggle<CR>
let g:NERDTreeDirArrowExpandable="+"
let g:NERDTreeDirArrowCollapsible="~"

" =========== tagbar mappings/settings ==================
nmap <leader>t :TagbarToggle<CR>

" ============= coc.nvim settings/mappings ===============
" you need to cd ~/.local/share/nvim/plugged/coc.nvim and run 'yarn install'
" :CocInstall coc-clangd
" :CocInstall coc-sh
" :CocInstall coc-python
" :CocInstall coc-snippets
" :CocCommand snippets.edit... FOR EACH FILE TYPE
inoremap <expr> <Tab> pumvisible() ? coc#_select_confirm() : "<Tab>"
nnoremap <C-l> :call CocActionAsync('jumpDefinition')<CR>

" ============== vim-airline mappings/settings =========================
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" vim-airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

" ============== barbar.nvim mappings/settings =================
" <ALT> + , goto previous buffer
nnoremap <silent>    <A-,> :BufferPrevious<CR>
" <ALT> + . goto next buffer
nnoremap <silent>    <A-.> :BufferNext<CR>
nnoremap <silent>    <A-<> :BufferMovePrevious<CR>
nnoremap <silent>    <A->> :BufferMoveNext<CR>
nnoremap <silent>    <A-1> :BufferGoto 1<CR>
nnoremap <silent>    <A-2> :BufferGoto 2<CR>
nnoremap <silent>    <A-3> :BufferGoto 3<CR>
nnoremap <silent>    <A-4> :BufferGoto 4<CR>
nnoremap <silent>    <A-5> :BufferGoto 5<CR>
nnoremap <silent>    <A-6> :BufferGoto 6<CR>
nnoremap <silent>    <A-7> :BufferGoto 7<CR>
nnoremap <silent>    <A-8> :BufferGoto 8<CR>
nnoremap <silent>    <A-9> :BufferLast<CR>
nnoremap <silent>    <A-c> :BufferClose<CR>

" ===================== nerdcommenter mappings/settings ==============
let g:NERDSpaceDelims = 1

" ================== vim-fugitive mappings/settings ====================
" map <leader>gw :Git grep <cword><cr>

" ================== vimwiki mappings/settings =====================    
let g:vimwiki_list=[{'path': '~/tasks/', 'ext': '.txt'}, {'path': '~/docs/', 'ext': '.txt'}]
