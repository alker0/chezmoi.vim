let s:cpo_save = &cpo
set cpo-=C
set cpo-=l
set cpo-=\

function! chezmoi#filetype#handle_chezmoi_filetype() abort
  if did_filetype() || exists('b:chezmoi_detecting_fixed')
    return
  endif

  call s:reset_buf_vars()
  let original_abs_path = expand('<amatch>:p')

  if !exists('s:special_dir_patterns')
    let s:special_dir_patterns = s:get_special_dir_patterns()
  endif

  if exists('g:chezmoi#detect_ignore_pattern') &&
      \ original_abs_path =~# g:chezmoi#detect_ignore_pattern
    return
  elseif original_abs_path =~# s:special_dir_patterns['ignore_remove']
    let b:chezmoi_target_path = original_abs_path

    setfiletype chezmoitmpl
  elseif original_abs_path =~# s:special_dir_patterns['templates']
    call chezmoi#filetype#handle_chezmoitemplates_file(original_abs_path)
  elseif original_abs_path =~# s:special_dir_patterns['data']
    call chezmoi#filetype#handle_managed_file(original_abs_path)
  elseif original_abs_path =~# s:special_dir_patterns['config']
    call chezmoi#filetype#handle_managed_file(original_abs_path)
  elseif original_abs_path =~# s:special_dir_patterns['other_dot_items']
   return
  else
    call chezmoi#filetype#handle_managed_file(original_abs_path)
  endif
endfunction

function! s:reset_buf_vars()
  " unlet! b:chezmoi_detecting_fixed
  unlet! b:chezmoi_target_path
  unlet! b:chezmoi_original_filetype
  unlet! b:chezmoi_original_syntax
endfunction

function! s:get_special_dir_patterns()
  " g:chezmoi#source_dir_path should be defined in /filetype.vim
  let dir_prefix = '^' . g:chezmoi#source_dir_path . '/\v'
  let patterns = {}
  let patterns.ignore_remove = dir_prefix . '\.chezmoi%(ignore|remove)$'
  let patterns.templates = dir_prefix . '\.chezmoitemplates/.+'
  let patterns.data = dir_prefix . '\.chezmoidata\.%(json|yaml|toml)$'
  let patterns.config = dir_prefix . '\.chezmoi\.%(json|yaml|toml|hcl|plist|properties)\.tmpl$'
  let patterns.other_dot_items = dir_prefix . '%([^/]+/){-}\.'
  return patterns
endfunction

function! chezmoi#filetype#handle_chezmoitemplates_file(original_abs_path)
  let b:chezmoi_target_path = a:original_abs_path
  let without_tmpl = substitute(a:original_abs_path, '\C\.tmpl$', '', '')

  call s:handle_fixed_path(a:original_abs_path, without_tmpl)

  if empty(&filetype)
    setlocal filetype=chezmoitmpl
  elseif original_abs_path ==# without_tmpl
    setlocal filetype+=.chezmoitmpl
  endif
endfunction

function! chezmoi#filetype#handle_managed_file(original_abs_path)
  let fixed_name = s:get_fixed_name(fnamemodify(a:original_abs_path, ':t'))

  if empty(fixed_name)
    return
  endif

  let until_dot_prefix = s:get_fixed_dir(a:original_abs_path) . '/' . fixed_name
  let until_literal_prefix = substitute(until_dot_prefix, '\C/\zsdot_', '.', 'g')
  let b:chezmoi_target_path = substitute(until_literal_prefix, '\C/\zsliteral_', '', 'g')

  call s:handle_fixed_path(a:original_abs_path, b:chezmoi_target_path)
endfunction

function! s:handle_fixed_path(original_path, fixed_path)
  if !exists('b:chezmoi_detecting_fixed')
    let b:chezmoi_detecting_fixed = 1

    execute 'doau filetypedetect BufRead ' . fnameescape(a:fixed_path)
    unlet b:chezmoi_detecting_fixed

    if fnamemodify(a:original_path, ':e') ==# 'tmpl'
      let b:chezmoi_original_filetype = &filetype

      if empty(b:chezmoi_original_filetype) || b:chezmoi_original_filetype ==# 'chezmoitmpl'
        setfiletype chezmoitmpl
      else
        if exists('b:current_syntax')
          let b:chezmoi_original_syntax = b:current_syntax
        endif

        setlocal filetype+=.chezmoitmpl
      endif
    endif
  endif
endfunction

function! s:get_name_prefix_pattern()
  let prefix_list = ['run', 'create', 'modify', 'before', 'after',
    \ 'private', 'empty', 'executable', 'symlink', 'once']
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
    \ '\C\v/\zs%(exact_)?%(private_)?\ze%(literal_)?', '', 'g')
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
