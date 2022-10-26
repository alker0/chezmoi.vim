if !exists('b:chezmoi_original_syntax') || b:chezmoi_original_syntax !~# '\v<%(sh|posix)>'
  finish
endif

syn case match

call chezmoi#syntax#addIntoCluster('shCommandSubList', 'shTestList', 'shCommentGroup')
call chezmoi#syntax#addIntoSyntaxGroup('shSingleQuote', 'shDoubleQuote', 'shExSingleQuote', 'shExDoubleQuote')

" vim: sw=2 ts=2 et
