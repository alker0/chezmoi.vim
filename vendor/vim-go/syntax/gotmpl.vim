" Copyright 2011 The Go Authors. All rights reserved.
" Use of this source code is governed by a BSD-style
" license that can be found in the LICENSE file.
"
" gotmpl.vim: Vim syntax file for Go templates.

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

syn case match

" Go escapes
syn match       goEscapeOctal       display contained "\\[0-7]\{3}"
syn match       goEscapeC           display contained +\\[abfnrtv\\'"]+
syn match       goEscapeX           display contained "\\x\x\{2}"
syn match       goEscapeU           display contained "\\u\x\{4}"
syn match       goEscapeBigU        display contained "\\U\x\{8}"
syn match       goEscapeError       display contained +\\[^0-7xuUabfnrtv\\'"]+

hi def link     goEscapeOctal       goSpecialString
hi def link     goEscapeC           goSpecialString
hi def link     goEscapeX           goSpecialString
hi def link     goEscapeU           goSpecialString
hi def link     goEscapeBigU        goSpecialString
hi def link     goSpecialString     Special
hi def link     goEscapeError       Error

" Strings and their contents
syn cluster     goStringGroup       contains=goEscapeOctal,goEscapeC,goEscapeX,goEscapeU,goEscapeBigU,goEscapeError
syn region      goString            oneline contained start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=@goStringGroup
syn region      goRawString         oneline contained start=+`+ end=+`+

hi def link     goString            String
hi def link     goRawString         String

" Characters; their contents
syn cluster     goCharacterGroup    contains=goEscapeOctal,goEscapeC,goEscapeX,goEscapeU,goEscapeBigU
syn region      goCharacter         oneline contained start=+'+ skip=+\\\\\|\\'+ end=+'+ contains=@goCharacterGroup

hi def link     goCharacter         Character

" Integers
syn match       goDecimalInt        display contained "\v<\d+([Ee]\d+)?>"
syn match       goHexadecimalInt    display contained "\v<0x\x+>"
syn match       goOctalInt          display contained "\v<0\o+>"
syn match       goOctalError        display contained "\v<0\o*[89]\d*>"
syn cluster     goInt               contains=goDecimalInt,goHexadecimalInt,goOctalInt
" Floating point
syn match       goFloat             display contained "\v<\d+\.\d*([Ee][-+]\d+)?>"
syn match       goFloat             display contained "\v<\.\d+([Ee][-+]\d+)?>"
syn match       goFloat             display contained "\v<\d+[Ee][-+]\d+>"
" Imaginary literals
syn match       goImaginary         display contained "\v<\d+i>"
syn match       goImaginary         display contained "\v<\d+\.\d*([Ee][-+]\d+)?i>"
syn match       goImaginary         display contained "\v<\.\d+([Ee][-+]\d+)?i>"
syn match       goImaginary         display contained "\v<\d+[Ee][-+]\d+i>"

hi def link     goInt        Number
hi def link     goFloat      Number
hi def link     goImaginary  Number

" Token groups
syn cluster     goTmplLiteral     contains=goString,goRawString,goCharacter,@goInt,goFloat,goImaginary
syn keyword     goTmplControl     contained   if else end range with template define block
syn keyword     goTmplFunctions   contained   and html index js len not or print printf println urlquery eq ne lt le gt ge slice
syn match       goTmplVariable    display contained   /\v\$[a-zA-Z0-9_]*>/
syn match       goTmplIdentifier  display contained   /\v\.[^[:blank:]}]+>/

hi def link goTmplVariable Identifier
hi def link goTmplIdentifier Identifier

hi def link     goTmplControl        Keyword
hi def link     goTmplFunctions      Function
hi def link     goTmplVariable       Special

syn cluster goTmplItems contains=@goTmplLiteral,goTmplControl,goTmplFunctions,goTmplVariable,goTmplIdentifier

if !exists('b:tmpl_region_defined')
  syn region goTmplAction start="{{" end="}}" contains=@goTmplItems containedin=ALLBUT,@goTmplActions,@goTmplItems
  syn region goTmplComment start="{{\v(- )?/\*" end="\v\*/( -)?\V}}" containedin=ALLBUT,@goTmplActions,@goTmplItems
endif
unlet! b:tmpl_region_defined

hi def link goTmplAction PreProc
hi def link goTmplComment Comment

syn sync match goTmplActionSync grouphere goTmplAction '{{'
syn sync match goTmplActionSync grouphere NONE '}}'

syn sync match goTmplCommentSync grouphere goTmplComment '{{\v(- )?/\*'
syn sync match goTmplCommentSync grouphere NONE '\v/\*(- )/?\V}}'

syn cluster goTmplActions contains=goTmplAction,goTmplComment

let b:current_syntax = "gotmpl"

" vim: sw=2 ts=2 et
