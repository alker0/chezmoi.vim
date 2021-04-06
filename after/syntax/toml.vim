if !exists('b:chezmoi_original_syntax') || b:chezmoi_original_syntax !~# '\v<toml>'
  finish
endif

syn case match

call chezmoi#syntax#addIntoCluster('tomlValue')
call chezmoi#syntax#addIntoSyntaxGroup('tomlComment', 'tomlString')

" vim: sw=2 ts=2 et
