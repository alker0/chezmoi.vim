if !exists('b:chezmoi_original_syntax') || b:chezmoi_original_syntax !~# '\v<vim>'
  finish
endif

syn case match

call chezmoi#syntax#addIntoCluster('vimStringGroup', 'vimFuncBodyList', 'vimCommentGroup')
call chezmoi#syntax#addIntoSyntaxGroup('vimEcho', 'vimString', 'vimSetEqual', 'vimExecute')

" vim: sw=2 ts=2 et
