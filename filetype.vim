if exists('g:chezmoi#_loaded')
  finish
endif
let g:chezmoi#_loaded = 1

if has('unix') " `unix` also includes cygwin
  function! s:fix_path_delims(text) abort
    return a:text
  endfunction
else
  function! s:fix_path_delims(text) abort
    return tr(a:text, '\', '/')
  endfunction
endif

if !exists('g:chezmoi#source_dir_path')
  let g:chezmoi#source_dir_path = ''

  if exists('g:chezmoi#use_external')
    if type(g:chezmoi#use_external) == v:t_number || type(g:chezmoi#use_external) == v:t_bool
      if g:chezmoi#use_external
        let g:chezmoi#use_external = 'chezmoi'
      else
        let g:chezmoi#use_external = ''
      endif
    endif

    if executable( g:chezmoi#use_external )
      let g:chezmoi#use_external = exepath( g:chezmoi#use_external )
      let g:chezmoi#source_dir_path = glob(trim(system(shellescape(g:chezmoi#use_external) . ' source-path'), "\r\n", 2))
    else
      let g:chezmoi#use_external = ''
    endif
  endif

  if empty(g:chezmoi#source_dir_path)
    if !empty($XDG_DATA_HOME)
      let g:chezmoi#source_dir_path = trim(s:fix_path_delims($XDG_DATA_HOME), '/', 2) . '/chezmoi'
    else
      let g:chezmoi#source_dir_path = s:fix_path_delims(expand('~')) . '/.local/share/chezmoi'
    endif

    let s:chezmoi_root_file = glob( g:chezmoi#source_dir_path . "/.chezmoiroot" )
    if !empty( s:chezmoi_root_file )
      let s:chezmoiroot = trim(readfile(s:chezmoi_root_file, '', 1)[0], "\r\n", 2)
      let s:chezmoiroot = trim(s:chezmoiroot, '/', 2)
      " g:chezmoi#source_dir_path has already trimmed suffixes of path delimiters
      let g:chezmoi#source_dir_path = g:chezmoi#source_dir_path . '/' . s:chezmoiroot
      unlet s:chezmoiroot
    endif
    unlet s:chezmoi_root_file
  endif
else
  if g:chezmoi#source_dir_path[0] !=# '/'
    let g:chezmoi#source_dir_path = fnamemodify(g:chezmoi#source_dir_path, ':p')
  endif
  let g:chezmoi#source_dir_path = trim(s:fix_path_delims(g:chezmoi#source_dir_path), '/', 2)
endif

if has('unix')
  let s:source_dir_pattern = '\V' . escape(g:chezmoi#source_dir_path, ' \') . '/\*'
else
  " `\V` mode makes slash(/) not work as path delimiter on Windows
  let s:source_dir_pattern = '\c' . escape(g:chezmoi#source_dir_path, '.~$[ \') . '/*'
endif

augroup chezmoi_filetypedetect
  autocmd!

  execute 'autocmd BufNewFile,BufRead '. s:source_dir_pattern . ' call chezmoi#filetype#handle_chezmoi_filetype()'
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
