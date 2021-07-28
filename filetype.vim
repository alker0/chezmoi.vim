if exists('g:chezmoi#_loaded')
  finish
endif
let g:chezmoi#_loaded = 1

if !exists('g:chezmoi#source_dir_path')
  if empty($XDG_DATA_HOME)
    let g:chezmoi#source_dir_path = $HOME . '/.local/share/chezmoi'
  else
    let g:chezmoi#source_dir_path = $XDG_DATA_HOME . '/chezmoi'
  endif
endif

augroup chezmoi_filetypedetect
  autocmd!

  execute 'autocmd BufNewFile,BufRead '. g:chezmoi#source_dir_path . '/* call chezmoi#filetype#handle_chezmoi_filetype()'
  " autocmd BufNewFile,BufRead */chezmoi/* call chezmoi#filetype#handle_chezmoi_filetype()
augroup END

" vim: sw=2 ts=2 et
