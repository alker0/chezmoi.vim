if  !exists('b:chezmoi_original_syntax') || b:chezmoi_original_syntax !~# '\v<conf>'
  if  !exists('b:chezmoi_target_path') || b:chezmoi_target_path !~# '\v/\.chezmoi%(ignore|remove)$'
    finish
  endif
endif

syn case match

call chezmoi#syntax#addIntoSyntaxGroup('confComment')

" vim: sw=2 ts=2 et
