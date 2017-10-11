" Maintainer:	Gilboa Davara <gilboad at gmail dot com>
" Last Change:	$Date 2006/08/24 $
" Version:	$Id: 1." local syntax file - set colors on a per-machine basis:
" vim: tw=0 ts=4 sw=4
" Vim color file

hi clear
set background=dark
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "gilboa"
hi Normal		  guifg=white  guibg=black
hi Scrollbar	  guifg=darkcyan guibg=cyan
hi Menu			  guifg=black guibg=cyan
hi SpecialKey	  term=bold  cterm=bold  ctermfg=darkred  guifg=Blue
hi NonText		  term=bold  cterm=bold  ctermfg=darkred  gui=bold	guifg=Blue
hi Directory	  term=bold  cterm=bold  ctermfg=brown	guifg=Blue
hi ErrorMsg		  term=standout  cterm=bold  ctermfg=grey  ctermbg=blue  guifg=White  guibg=Red
hi Search		  term=reverse	ctermfg=white  ctermbg=red	guifg=white  guibg=Red
hi MoreMsg		  term=bold  cterm=bold  ctermfg=darkgreen	gui=bold  guifg=SeaGreen
hi ModeMsg		  term=bold  cterm=bold  gui=bold  guifg=White	guibg=Blue
hi LineNr		  term=underline  cterm=bold  ctermfg=darkcyan	guifg=Yellow
hi Question		  term=standout  cterm=bold  ctermfg=darkgreen	gui=bold  guifg=Green
hi StatusLine	  term=bold,reverse  cterm=bold ctermfg=lightblue ctermbg=white gui=bold guifg=blue guibg=white
hi StatusLineNC   term=reverse	ctermfg=white ctermbg=lightblue guifg=white guibg=blue
hi Title		  term=bold  cterm=bold  ctermfg=darkmagenta  gui=bold	guifg=Magenta
hi Visual		  term=reverse	cterm=reverse  gui=reverse
hi WarningMsg	  term=standout  cterm=bold  ctermfg=darkblue  guifg=Red
hi Cursor		  guifg=bg	guibg=Green
hi Comment		  term=bold  cterm=bold ctermfg=green  guifg=#80ff80
hi Special		  term=bold  cterm=bold ctermfg=red  guifg=Orange
hi Identifier	  term=underline   ctermfg=brown guifg=#50ffff
hi Macro		  term=bold  cterm=bold ctermfg=brown  gui=bold  guifg=#8080ff
hi String		  term=bold  cterm=bold ctermfg=red	guifg=#ffb0b0
hi Statement	  term=bold  cterm=bold ctermfg=yellow	gui=bold  guifg=#ffff80
hi PreProc		  term=underline  ctermfg=darkblue	gui=bold guifg=white
hi Constant		  term=underline  cterm=bold ctermfg=grey  gui=bold guifg=#909090
hi Type			  term=underline  cterm=bold ctermfg=lightblue  gui=bold  guifg=#8080ff
hi Structure	  term=underline  cterm=bold ctermfg=darkred  gui=bold  guifg=#e06060
hi Error		  term=reverse	ctermfg=darkcyan  ctermbg=black  guifg=Red	guibg=Black
hi Todo			  term=standout  ctermfg=black	ctermbg=darkcyan  guifg=Blue  guibg=Yellow
hi CursorLine	  term=underline  guibg=#555555
hi CursorColumn	  term=underline  guibg=#555555
hi MatchParen	  term=reverse  guibg=Blue
hi TabLine		  term=bold,reverse  cterm=bold ctermfg=lightblue ctermbg=white gui=bold guifg=blue guibg=white
hi TabLineFill	  term=bold,reverse  cterm=bold ctermfg=lightblue ctermbg=white gui=bold guifg=blue guibg=white
hi TabLineSel	  term=reverse	ctermfg=white ctermbg=lightblue guifg=white guibg=blue
hi link IncSearch		Visual
hi link Character		String
hi link Number			Constant
hi link Boolean			Constant
hi link Float			Number
hi link Function		Identifier
hi link Conditional		Statement
hi link Repeat			Statement
hi link Label			Statement
hi link Operator		Statement
hi link Keyword			Statement
hi link Exception		Statement
hi link Include			PreProc
hi link Define			PreProc
hi link PreCondit		PreProc
hi link StorageClass	Type
hi link Typedef			Type
hi link Tag				Special
hi link SpecialChar		Special
hi link Delimiter		Special
hi link SpecialComment	Special
hi link Debug			Special
