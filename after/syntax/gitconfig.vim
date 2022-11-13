if !exists('b:chezmoi_original_syntax') || b:chezmoi_original_syntax !~# '\v<gitconfig>'
  finish
endif

syn case match

syn region gitConfigVariableTmpl start=/{{/ end=/}}/ contained keepend nextgroup=gitConfigVariableBetweenTmpl,gitConfigVariableRightEnd,gitConfigVariableTmpl
syn match gitConfigVariable /^\s*\zs\a[a-z0-9-]*\ze{{/ nextgroup=gitConfigVariableTmpl
syn match gitConfigVariableStartFromTmpl /^\s*\ze{{.*}}[a-z0-9-]*\s*=/ keepend nextgroup=gitConfigVariableTmpl
syn match gitConfigVariableBetweenTmpl /[a-z0-9-]\+\ze{{/ contained nextgroup=gitConfigVariableTmpl
syn match gitConfigVariableRightEnd /\v[a-z0-9-]*\ze\s*%([=#;]|$)/ contained nextgroup=gitConfigAssignment skipwhite
hi def link gitConfigVariableBetweenTmpl gitConfigVariableForTmpl
hi def link gitConfigVariableRightEnd gitConfigVariableForTmpl
hi def link gitConfigVariableForTmpl Identifier

" vim: sw=2 ts=2 et
