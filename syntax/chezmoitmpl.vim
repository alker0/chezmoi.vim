if exists("b:current_syntax") && b:current_syntax =~# '\v<%(gotmpl|chezmoitmpl)>'
  finish
endif

unlet! b:current_syntax

source <sfile>:h/gotmpl.vim

syn keyword chezmoiTmplHelperFunctions contained bitwarden bitwardenAttachment bitwardenFields gitHubKeys gopass include ioreg joinPath keepassxc keepassxcAttribute keyring
syn keyword chezmoiTmplHelperFunctions contained lastpass lastpassRaw lookPath onepassword onepasswordDocument onepasswordDetailsFields output
syn keyword chezmoiTmplHelperFunctions contained pass promptBool promptInt promptString secret secretJSON stat stdinIsATTY vault

hi def link chezmoiTmplHelperFunctions Function

syn cluster goTmplItems add=chezmoiTmplHelperFunctions

if exists('b:chezmoi_original_syntax')
  let b:current_syntax = b:chezmoi_original_syntax . '+chezmoitmpl'
else
  let b:current_syntax = 'chezmoitmpl'
endif

" vim: sw=2 ts=2 et
