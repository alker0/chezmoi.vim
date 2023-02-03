if exists("b:current_syntax") && b:current_syntax =~# '\v<%(gotmpl|chezmoitmpl)>'
  finish
endif

let s:cpo_save = &cpo
" enable line continuation
set cpo-=C

unlet! b:current_syntax

source <sfile>:h/gotmpl.vim

syn keyword chezmoiTmplFunctions contained
\ awsSecretsManager awsSecretsManagerRaw bitwarden bitwardenAttachment
\ bitwardenFields comment completion decrypt encrypt eqFold exit fromIni
\ fromToml fromYaml gitHubKeys gitHubLatestRelease gitHubLatestTag glob gopass
\ gopassRaw hexDecode hexEncode include includeTemplate ioreg joinPath
\ keepassxc keepassxcAttachment keepassxcAttribute keeper keeperDataFields
\ keeperFindPassword keyring lastpass lastpassRaw lookPath lstat
\ mozillaInstallHash onepassword onepasswordDetailsFields onepasswordDocument
\ onepasswordItemFields onepasswordRead output pass passFields passRaw passhole
\ promptBool promptBoolOnce promptInt promptIntOnce promptString
\ promptStringOnce quoteList replaceAllRegex secret secretJSON setValueAtPath
\ stat stdinIsATTY toIni toToml toYaml vault writeToStdout

hi def link chezmoiTmplFunctions Function

syn cluster goTmplItems add=chezmoiTmplFunctions

if exists('b:chezmoi_original_syntax')
  let b:current_syntax = b:chezmoi_original_syntax . '+chezmoitmpl'
else
  let b:current_syntax = 'chezmoitmpl'
endif

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
