if exists('g:chezmoi#_loaded')
  finish
endif
let g:chezmoi#_loaded = 1

if !exists('g:chezmoi#source_dir_path')
  if !empty($XDG_DATA_HOME)
    let g:chezmoi#source_dir_path = substitute($XDG_DATA_HOME, '\C\\', '/', 'g') . '/chezmoi'
  else
    let g:chezmoi#source_dir_path = expand('~') . '/.local/share/chezmoi'
  endif

  if !has('unix') " `unix` also includes cygwin
    let g:chezmoi#source_dir_path = substitute(g:chezmoi#source_dir_path, '\\', '/', 'g')
  endif
endif

augroup chezmoi_filetypedetect
  autocmd!

  execute 'autocmd BufNewFile,BufRead '. g:chezmoi#source_dir_path . '/* call chezmoi#filetype#handle_chezmoi_filetype()'
augroup END

if has('unix')
  if empty($TMPDIR)
    autocmd chezmoi_filetypedetect  BufNewFile,BufRead /tmp/chezmoi-edit* call chezmoi#filetype#handle_chezmoi_filetype_hardlink()
  else
    autocmd chezmoi_filetypedetect  BufNewFile,BufRead $TMPDIR/chezmoi-edit* call chezmoi#filetype#handle_chezmoi_filetype_hardlink()
  endif
" elseif !empty($TEMP) " for windows
"   autocmd chezmoi_filetypedetect  BufNewFile,BufRead $TEMP/chezmoi-edit* call chezmoi#filetype#handle_chezmoi_filetype_hardlink()
endif

" vim: sw=2 ts=2 et
