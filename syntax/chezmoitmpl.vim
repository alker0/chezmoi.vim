if exists("b:current_syntax") && b:current_syntax =~# '\v<%(gotmpl|chezmoitmpl)>'
  finish
endif

unlet! b:current_syntax

source <sfile>:h/gotmpl.vim

syn keyword chezmoiTmplHelperFunctions contained bitwarden bitwardenAttachment bitwardenFields decrypt encrypt exit fromJson fromYaml gitHubKeys gitHubLatestRelease
syn keyword chezmoiTmplHelperFunctions contained gopass gopassRaw include ioreg joinPath keepassxc keepassxcAttribute keyring lastpass lastpassRaw lookPath
syn keyword chezmoiTmplHelperFunctions contained mozillaInstallHash onepassword onepasswordDocument onepasswordDetailsFields onepasswordItemFields output
syn keyword chezmoiTmplHelperFunctions contained pass passRaw promptBool promptInt promptString secret secretJSON stat stdinIsATTY toYaml vault writeToStdout

hi def link chezmoiTmplHelperFunctions Function

syn cluster goTmplItems add=chezmoiTmplHelperFunctions

if exists('b:chezmoi_original_syntax')
  let b:current_syntax = b:chezmoi_original_syntax . '+chezmoitmpl'
else
  let b:current_syntax = 'chezmoitmpl'
endif

" vim: sw=2 ts=2 et
