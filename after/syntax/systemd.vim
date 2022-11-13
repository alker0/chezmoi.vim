if !exists('b:chezmoi_original_syntax') || b:chezmoi_original_syntax !~# '\v<systemd>'
  finish
endif

syn case match

syn match sdUInt /\d*{{/ contained nextgroup=sdUInt,sdErr
syn match sdInt /-\?\zs\d*{{/ contained nextgroup=sdInt,sdErr
syn match sdOctal /\%(0\o\{,4}\)\?{{/ contained nextgroup=sdOctal,sdErr
syn match sdDatasizeEnd /\d*[KMGT]/ contained nextgroup=sdDatasize,sdErr
syn match sdDatasize /\d*{{/ contained nextgroup=sdDatasize,sdDatasizeEnd,sdErr
syn match sdFilename +\%(/.*\)\?{{.*+ contained
syn match sdPercentEnd /\d*%/ contained
syn match sdPercent /\d*{{/ contained nextgroup=sdPercent,sdPercentEnd,sdErr
syn match sdBool /{{/ contained nextgroup=sdBool,sdErr

" vim: sw=2 ts=2 et
