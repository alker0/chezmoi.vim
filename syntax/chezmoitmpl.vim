if exists("b:current_syntax") && b:current_syntax =~# '\v<%(gotmpl|chezmoitmpl)>'
  finish
endif

unlet! b:current_syntax

source <sfile>:h/gotmpl.vim

if exists('b:chezmoi_original_syntax')
  let b:current_syntax = b:chezmoi_original_syntax . '+chezmoitmpl'
else
  let b:current_syntax = 'chezmoitmpl'
endif

" vim: sw=2 ts=2 et
