" Vim syntax file example
" Put it in ~/.vim/after/syntax/ and tailor to your needs.
" vim: set ft=vim :
" Highlight Class and Function names
syn match    cCustomParen    "(" contains=cParen contains=cCppParen
syn match    cCustomFunc     "\w\+\s*(" contains=cCustomParen
syn match    cCustomScope    "::"
syn match    cCustomClass    "\w\+\s*::" contains=cCustomScope

hi def link cCustomFunc  Function
hi def link cCustomClass Function
