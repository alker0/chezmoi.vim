if exists("b:current_syntax") && b:current_syntax =~# '\v<%(gotmpl|chezmoitmpl)>'
  finish
endif

unlet! b:current_syntax

source <sfile>:h/gotmpl.vim

syn keyword chezmoiTmplFunctions contained
\ awsSecretsManager awsSecretsManagerRaw bitwarden bitwardenAttachment
\ bitwardenFields comment decrypt encrypt exit fromToml fromYaml gitHubKeys
\ gitHubLatestRelease glob gopass gopassRaw include ioreg joinPath keepassxc
\ keepassxcAttachment keepassxcAttribute keeper keeperDataFields
\ keeperFindPassword keyring lastpass lastpassRaw lookPath mozillaInstallHash
\ onepassword onepasswordDetailsFields onepasswordDocument
\ onepasswordItemFields onepasswordRead output pass passFields passRaw
\ promptBool promptBoolOnce promptInt promptIntOnce promptString
\ promptStringOnce quoteList replaceAllRegex secret secretJSON stat stdinIsATTY
\ toToml toYaml vault writeToStdout

hi def link chezmoiTmplFunctions Function

syn cluster goTmplItems add=chezmoiTmplFunctions

if exists('b:chezmoi_original_syntax')
  let b:current_syntax = b:chezmoi_original_syntax . '+chezmoitmpl'
else
  let b:current_syntax = 'chezmoitmpl'
endif

" vim: sw=2 ts=2 et
