let s:cpo_save = &cpo
" enable line continuation
set cpo-=C
" enable special characters by backslash(\) in [] of regex
set cpo-=l
set cpo-=\

function! chezmoi#filetype#handle_chezmoi_filetype() abort
  if did_filetype() || exists('b:chezmoi_detecting_fixed')
    return
  endif

  call s:reset_buf_vars()
  let original_abs_path = expand('<amatch>:p')

  if exists('g:chezmoi#detect_ignore_pattern') &&
      \ original_abs_path =~# g:chezmoi#detect_ignore_pattern
    return
  endif

  if !exists('s:special_path_patterns')
    let s:special_path_patterns = s:get_special_path_patterns()
  endif

  let options = {}
  let options.need_name_fix = v:true
  let options.enable_tmpl_force = v:false

  if original_abs_path =~# s:special_path_patterns['scripts']
    if original_abs_path =~# s:special_path_patterns['scripts_dot']
      return
    endif
  elseif original_abs_path =~# s:special_path_patterns['ignore_remove']
    let b:chezmoi_target_path = original_abs_path
    setfiletype conf.chezmoitmpl
    return
  elseif original_abs_path =~# s:special_path_patterns['templates']
    call s:disable_artifacts()
    let options.source_path = original_abs_path
    let options.need_name_fix = v:false
    let options.enable_tmpl_force = v:true
  elseif original_abs_path =~# s:special_path_patterns['config'] ||
      \ original_abs_path =~# s:special_path_patterns['data']
    let options.need_name_fix = v:false
  elseif original_abs_path =~# s:special_path_patterns['external']
    let options.need_name_fix = v:false
    let options.enable_tmpl_force = v:true
  elseif original_abs_path =~# s:special_path_patterns['external_dir'] ||
       \ original_abs_path =~# s:special_path_patterns['other_dot_path']
   return
  endif

  call s:handle_source_file(original_abs_path, options)
endfunction

function! chezmoi#filetype#handle_chezmoi_filetype_hardlink() abort
  if did_filetype() || exists('b:chezmoi_detecting_fixed')
    return
  endif

  call s:reset_buf_vars()
  let original_abs_path = expand('<amatch>:p')

  if exists('g:chezmoi#detect_ignore_pattern') &&
      \ original_abs_path =~# g:chezmoi#detect_ignore_pattern
    return
  endif

  let options = {}
  let options.need_name_fix = v:false
  let options.enable_tmpl_force = v:false

  let replaced_to_source = substitute(original_abs_path, '\C^.\{-}/chezmoi-edit[^/]*\ze/', g:chezmoi#source_dir_path, '')
  call s:handle_source_file(replaced_to_source, options)
endfunction

function! s:handle_source_file(original_abs_path, options) abort
  " a:options.source_path (optional)
  " a:options.need_name_fix
  " a:options.enable_tmpl_force
  if a:options.need_name_fix
    let b:chezmoi_default_detect_target = s:get_fixed_path(a:original_abs_path)
  else
    let b:chezmoi_default_detect_target = substitute(a:original_abs_path, '\C\.tmpl$', '', '')
  endif

  if empty(b:chezmoi_default_detect_target)
    unlet b:chezmoi_default_detect_target
    return
  endif

  let b:chezmoi_source_path = get(a:options, 'source_path', b:chezmoi_default_detect_target)

  call s:run_default_detect(b:chezmoi_default_detect_target)

  if a:options.enable_tmpl_force
    call s:enable_template_force()
  else
    call s:enable_template_auto(a:original_abs_path)
  endif

  if exists('b:chezmoi_original_filetype') && b:chezmoi_original_filetype !=# &filetype
    execute 'autocmd chezmoi_filetypedetect FileType <buffer> call s:keep_filetype("' . &filetype . '")'
    autocmd VimEnter,BufWinEnter,CmdLineEnter <buffer> ++once autocmd! chezmoi_filetypedetect FileType <buffer>
  endif
endfunction

function! s:reset_buf_vars() abort
  " unlet! b:chezmoi_detecting_fixed
  unlet! b:chezmoi_target_path
  unlet! b:chezmoi_original_filetype
  unlet! b:chezmoi_original_syntax
endfunction

function! s:get_special_path_patterns() abort
  " g:chezmoi#source_dir_path should be defined in /filetype.vim
  " and cannot have / suffixes and \ delimiters but include \ as entry name
  let dir_prefix = '^\V' . escape(g:chezmoi#source_dir_path, '\') . '/\v'
  let config_extensions = '\.%(json|ya?ml|toml|hcl|plist|properties)'
  let other_dot_pattern = '%([^/]+/){-}\.'
  let patterns = {}
  let patterns.ignore_remove = dir_prefix . '\.chezmoi%(ignore|remove)$'
  let patterns.templates = dir_prefix . '\.chezmoitemplates/.+'
  let patterns.scripts = dir_prefix . '\.chezmoiscripts/.+'
  let patterns.scripts_dot = dir_prefix . '\.chezmoiscripts/' . other_dot_pattern
  let patterns.data = dir_prefix . '\.chezmoidata' . config_extensions . '$'
  let patterns.external = dir_prefix . '\.chezmoiexternal' . config_extensions . '$'
  let patterns.config = dir_prefix . '\.chezmoi' . config_extensions . '\.tmpl$'
  " Ignoring below paths should not be a problem:
  " .chezmoiversion
  " .chezmoiroot
  let patterns.external_dir = dir_prefix . '%([^/]+/){-}external_[^/]+/'
  let patterns.other_dot_path = dir_prefix . other_dot_pattern
  return patterns
endfunction

function! s:disable_artifacts() abort
  " Disable vim artifacts
  setlocal directory-=. " This maybe can not disable swap file
  setlocal backupdir-=.
  setlocal undodir-=. " In default, `undodir` will be empty

  " A swap file is created before file type detection so should remove that.
  let swap_file_path = swapname('%')
  if !empty(glob(swap_file_path))
    call delete(swap_file_path)
  endif
endfunction

function! s:run_default_detect(detect_target) abort
  if exists('b:chezmoi_detecting_fixed')
    return
  endif

  let b:chezmoi_detecting_fixed = 1
  execute 'doau filetypedetect BufRead ' . fnameescape(a:detect_target)
  unlet b:chezmoi_detecting_fixed
endfunction

function! s:enable_template_force() abort
  if empty(&filetype)
    setlocal filetype=chezmoitmpl
  elseif &filetype !~# '\<chezmoitmpl\>'
    if exists('b:current_syntax')
      let b:chezmoi_original_syntax = b:current_syntax
    endif

    setlocal filetype+=.chezmoitmpl
  endif
endfunction

function! s:enable_template_auto(original_path) abort
  if fnamemodify(a:original_path, ':e') !=# 'tmpl'
    return
  endif

  let b:chezmoi_original_filetype = &filetype

  if empty(b:chezmoi_original_filetype) || b:chezmoi_original_filetype ==# 'chezmoitmpl'
    setfiletype chezmoitmpl
  else
    if exists('b:current_syntax')
      let b:chezmoi_original_syntax = b:current_syntax
    endif

    setlocal filetype+=.chezmoitmpl
  endif
endfunction

function! s:keep_filetype(fixed_filetype)
  let &filetype = a:fixed_filetype
endfunction

function! s:get_fixed_path(original_abs_path) abort
  let fixed_name = s:get_fixed_name(fnamemodify(a:original_abs_path, ':t'))

  if empty(fixed_name)
    return ''
  endif

  let fixed_until_dot = s:get_fixed_dir(a:original_abs_path) . '/' . fixed_name
  let fixed_until_literal = substitute(fixed_until_dot, '\C/\zsdot_', '.', 'g')
  return substitute(fixed_until_literal, '\C/\zsliteral_', '', 'g')
endfunction

function! s:get_fixed_name(original_name) abort
  if !exists('s:name_prefix_pattern')
    let s:name_prefix_pattern = s:get_name_prefix_pattern()
  endif

  return substitute(a:original_name,
    \ '\C\v^' . s:name_prefix_pattern . '|%(\.literal)?%(\.tmpl)?$', '', 'g')
endfunction

function! s:get_name_prefix_pattern() abort
  let prefix_list = ['create', 'modify', 'remove', 'run', 'encrypted', 'private', 'readonly',
    \ 'executable', 'once', 'onchange', 'before', 'after', 'symlink', 'empty']
  return join(map(prefix_list, '"%(" . v:val . "_)?"'), '')
endfunction

function! s:get_fixed_dir(original_abs_path) abort
  return substitute(fnamemodify(a:original_abs_path, ':h'),
    \ '\C\v/\zs%(remove_)?%(exact_)?%(private_)?%(readonly_)?\ze%(literal_)?', '', 'g')
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
