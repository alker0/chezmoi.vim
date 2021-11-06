if exists("b:current_syntax") && b:current_syntax =~# '\v<%(gotmpl|chezmoitmpl)>'
  finish
endif

unlet! b:current_syntax

source <sfile>:h/gotmpl.vim

syn keyword chezmoiTmplHelperFunctions contained bitwarden bitwardenAttachment bitwardenFields decrypt enctypt fromJson gitHubKeys gopass gopassRaw
syn keyword chezmoiTmplHelperFunctions contained include ioreg joinPath keepassxc keepassxcAttribute keyring lastpass lastpassRaw lookPath mozillaInstallHash
syn keyword chezmoiTmplHelperFunctions contained onepassword onepasswordDocument onepasswordDetailsFields onepasswordItemFields output pass passRaw
syn keyword chezmoiTmplHelperFunctions contained promptBool promptInt promptString secret secretJSON stat stdinIsATTY vault writeToStdout

hi def link chezmoiTmplHelperFunctions Function

syn cluster goTmplItems add=chezmoiTmplHelperFunctions

if exists('b:chezmoi_original_syntax')
  let b:current_syntax = b:chezmoi_original_syntax . '+chezmoitmpl'
else
  let b:current_syntax = 'chezmoitmpl'
endif

" vim: sw=2 ts=2 et
