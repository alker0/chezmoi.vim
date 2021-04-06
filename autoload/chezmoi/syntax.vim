function chezmoi#syntax#addIntoCluster(...) abort
  " ==== add into `cluster` ====
  for cl in a:000
    execute 'syn cluster ' . cl . ' add=@goTmplActions'
  endfor
endfunction

function chezmoi#syntax#addIntoSyntaxGroup(...) abort
  " ==== add into `region group` ====
  let targets = join(a:000, ',')
  execute 'syn region goTmplAction start="{{" end="}}" contains=@goTmplItems containedin=' . targets
  execute 'syn region goTmplComment start=+{{\v%(- )?/\*+ end=+\v\*/%( -)?\V}}+ contains=@goTmplItems containedin=' . targets
  let b:tmpl_region_defined = 1
endfunction

" vim: sw=2 ts=2 et
