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

  if !exists('s:special_path_patterns')
    let s:special_path_patterns = s:get_special_path_patterns()
  endif

  if exists('g:chezmoi#detect_ignore_pattern') &&
      \ original_abs_path =~# g:chezmoi#detect_ignore_pattern
    return
  elseif original_abs_path =~# s:special_path_patterns['ignore_remove']
    let b:chezmoi_target_path = original_abs_path

    setfiletype chezmoitmpl
  elseif original_abs_path =~# s:special_path_patterns['templates']
    call chezmoi#filetype#handle_chezmoitemplates_file(original_abs_path)
  elseif original_abs_path =~# s:special_path_patterns['data']
    call chezmoi#filetype#handle_file_without_fix_naming(original_abs_path)
  elseif original_abs_path =~# s:special_path_patterns['config']
    call chezmoi#filetype#handle_file_without_fix_naming(original_abs_path)
  elseif original_abs_path =~# s:special_path_patterns['other_dot_path']
   return
  else
    call chezmoi#filetype#handle_managed_file(original_abs_path)
  endif
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
  else
    let target_path = substitute(original_abs_path, '\C^.\{-}/chezmoi-edit[^/]*/', g:chezmoi#source_dir_path, '')
    call chezmoi#filetype#handle_file_without_fix_naming(original_abs_path, target_path)
  endif
endfunction

function! s:reset_buf_vars()
  " unlet! b:chezmoi_detecting_fixed
  unlet! b:chezmoi_target_path
  unlet! b:chezmoi_original_filetype
  unlet! b:chezmoi_original_syntax
endfunction

function! s:get_special_path_patterns()
  " g:chezmoi#source_dir_path should be defined in /filetype.vim
  let dir_prefix = '^' . g:chezmoi#source_dir_path . '/\v'
  let patterns = {}
  let patterns.ignore_remove = dir_prefix . '\.chezmoi%(ignore|remove)$'
  let patterns.templates = dir_prefix . '\.chezmoitemplates/.+'
  let patterns.data = dir_prefix . '\.chezmoidata\.%(json|yaml|toml)$'
  let patterns.config = dir_prefix . '\.chezmoi\.%(json|yaml|toml|hcl|plist|properties)\.tmpl$'
  " Ignoring below paths should not be a problem:
  " .chezmoiversion
  " .chezmoiroot
  " .chezmoiscript
  " .chezmoiexternal
  let patterns.other_dot_path = dir_prefix . '%([^/]+/){-}\.'
  return patterns
endfunction

function! chezmoi#filetype#handle_chezmoitemplates_file(original_abs_path)
  let b:chezmoi_target_path = a:original_abs_path
  let without_tmpl = substitute(a:original_abs_path, '\C\.tmpl$', '', '')

  call s:handle_fixed_path(a:original_abs_path, without_tmpl)

  if empty(&filetype)
    setlocal filetype=chezmoitmpl
  elseif a:original_abs_path ==# without_tmpl
    setlocal filetype+=.chezmoitmpl
  endif
endfunction

function! chezmoi#filetype#handle_file_without_fix_naming(original_abs_path, ...)" target path is optional
  let b:chezmoi_target_path = get(a:, 1, a:original_abs_path)
  let without_tmpl = substitute(b:chezmoi_target_path, '\C\.tmpl$', '', '')

  call s:handle_fixed_path(a:original_abs_path, without_tmpl)
endfunction

function! chezmoi#filetype#handle_managed_file(original_abs_path)
  let fixed_name = s:get_fixed_name(fnamemodify(a:original_abs_path, ':t'))

  if empty(fixed_name)
    return
  endif

  let fixed_until_dot = s:get_fixed_dir(a:original_abs_path) . '/' . fixed_name
  let fixed_until_literal = substitute(fixed_until_dot, '\C/\zsdot_', '.', 'g')
  let b:chezmoi_target_path = substitute(fixed_until_literal, '\C/\zsliteral_', '', 'g')

  call s:handle_fixed_path(a:original_abs_path, b:chezmoi_target_path)
endfunction

function! s:handle_fixed_path(original_path, fixed_path)
  if exists('b:chezmoi_detecting_fixed')
    return
  endif

  let b:chezmoi_detecting_fixed = 1
  execute 'doau filetypedetect BufRead ' . fnameescape(a:fixed_path)
  unlet b:chezmoi_detecting_fixed

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

function! s:get_name_prefix_pattern()
  let prefix_list = ['create', 'modify', 'remove', 'run', 'encrypted', 'private', 'readonly',
    \ 'executable', 'once', 'onchange', 'before', 'after', 'symlink', 'empty']
  return join(map(prefix_list, '"%(" . v:val . "_)?"'), '')
endfunction

function! s:get_fixed_name(original_name) abort
  if !exists('s:name_prefix_pattern')
    let s:name_prefix_pattern = s:get_name_prefix_pattern()
  endif

  return substitute(a:original_name,
    \ '\C\v^' . s:name_prefix_pattern . '|%(\.literal)?%(\.tmpl)?$', '', 'g')
endfunction

function! s:get_fixed_dir(original_abs_path) abort
  return substitute(fnamemodify(a:original_abs_path, ':h'),
    \ '\C\v/\zs%(exact_)?%(private_)?%(readonly_)?\ze%(literal_)?', '', 'g')
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
