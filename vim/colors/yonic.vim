


"
" Vim color file
" Maintainer:	Yonatan cohen <yonic.swe@gmail.com>
"
"
" set background=light

hi clear

let colors_name = "yonic"

" Normal should come first
" hi Normal     ctermbg=Grey		ctermfg=Black guifg=Black  guibg=White
hi Normal     guifg=Black  guibg=White
hi Cursor     guifg=bg     guibg=fg
hi lCursor     guifg=bg     guibg=fg
" hi lCursor    guifg=NONE   guibg=Cyan 


" Note: we never set 'term' because the defaults for B&W terminals are OK
" hi DiffAdd    ctermbg=LightBlue    guibg=LightBlue
" hi DiffChange ctermbg=LightMagenta guibg=LightMagenta
" hi DiffDelete ctermfg=Blue	   ctermbg=LightCyan gui=bold guifg=Blue guibg=LightCyan
" hi DiffText   ctermbg=Red	   cterm=bold gui=bold guibg=Red

hi DiffAdd    ctermfg=Blue ctermbg=LightMagenta  cterm=bold gui=bold guibg=LightBlue      guifg=Blue
hi DiffChange ctermfg=Blue ctermbg=LightMagenta  cterm=bold gui=bold guibg=LightMagenta   guifg=Blue
hi DiffDelete ctermfg=Blue	ctermbg=LightMagenta  cterm=bold gui=bold                      guifg=Blue
hi DiffText   ctermfg=Red  ctermbg=LightMagenta  cterm=bold gui=bold                      guibg=Red

hi Directory  ctermfg=DarkBlue	   guifg=Blue
hi ErrorMsg   ctermfg=White	   ctermbg=DarkRed  guibg=Red	    guifg=White
hi Error        ctermfg=White	   ctermbg=LightGreen  guibg=Red	    guifg=White
hi FoldColumn ctermfg=DarkBlue	   ctermbg=Grey     guibg=Grey	    guifg=DarkBlue
hi Folded     ctermbg=Grey	   ctermfg=DarkBlue guibg=LightGrey guifg=DarkBlue
hi IncSearch  cterm=reverse	   gui=reverse
hi LineNr     ctermfg=Brown	   guifg=Brown
hi ModeMsg    cterm=bold	   gui=bold
hi MoreMsg    ctermfg=DarkGreen    gui=bold guifg=SeaGreen
hi NonText    ctermfg=Blue	   gui=bold guifg=gray guibg=white
hi Pmenu      guibg=LightBlue
hi PmenuSel   ctermfg=White	   ctermbg=DarkBlue  guifg=White  guibg=DarkBlue
hi Question   ctermfg=DarkGreen    gui=bold guifg=SeaGreen

" "hi Search     ctermfg=NONE	   ctermbg=Yellow guibg=Yellow guifg=NONE
" "hi Search		guifg=#90fff0 guibg=#2050d0	ctermfg=black ctermbg=White cterm=underline term=underline
hi Search		guifg=#90fff0 guibg=#2050d0	ctermfg=Blue ctermbg=White

hi SpecialKey ctermfg=DarkBlue	   guifg=Blue
hi StatusLine cterm=bold	   ctermbg=blue ctermfg=yellow guibg=gold guifg=blue
hi StatusLineNC	cterm=bold	   ctermbg=blue ctermfg=black  guibg=gold guifg=blue
hi Title      ctermfg=DarkMagenta  gui=bold guifg=Magenta
hi VertSplit  cterm=reverse	   gui=reverse

" "hi Visual     ctermbg=NONE	   cterm=reverse gui=reverse guifg=Grey guibg=fg
hi Visual     ctermfg=white ctermbg=LightGrey	   gui=reverse guifg=Grey guibg=fg

hi VisualNOS  cterm=underline,bold gui=underline,bold
hi WarningMsg ctermfg=DarkRed	   guifg=Red
hi WildMenu   ctermfg=Black	   ctermbg=Yellow    guibg=Yellow guifg=Black

" syntax highlighting
hi Comment    cterm=NONE ctermfg=DarkRed     gui=NONE guifg=red2
hi Constant   cterm=NONE ctermfg=DarkGreen   gui=NONE guifg=green3
" hi Identifier cterm=NONE ctermfg=DarkCyan    gui=NONE guifg=cyan4
hi Identifier cterm=bold ctermfg=DarkBlue    gui=NONE guifg=cyan4
hi PreProc    cterm=NONE ctermfg=DarkMagenta gui=NONE guifg=magenta3
hi Special    cterm=NONE ctermfg=DarkRed    gui=NONE guifg=deeppink
hi Statement  cterm=bold ctermfg=Blue	     gui=bold guifg=blue
hi Type	      cterm=NONE ctermfg=Blue	     gui=bold guifg=blue

" vim: sw=2
