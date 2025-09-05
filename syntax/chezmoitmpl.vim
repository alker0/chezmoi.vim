if exists("b:current_syntax") && b:current_syntax =~# '\v<%(gotmpl|chezmoitmpl)>'
  finish
endif

let s:cpo_save = &cpo
" enable line continuation
set cpo-=C

" Define keyword groups as strings
let s:onepasswordKeywords = [
  \ 'onepassword',
  \ 'onepasswordDetailsFields',
  \ 'onepasswordDocument',
  \ 'onepasswordItemFields',
  \ 'onepasswordRead'
  \ ]
let s:awsKeywords = [
  \ 'awsSecretsManager',
  \ 'awsSecretsManagerRaw'
  \ ]
let s:azureKeywords = [
  \ 'azureKeyVault'
  \ ]
let s:bitwardenKeywords = [
  \ 'bitwarden',
  \ 'bitwardenAttachment',
  \ 'bitwardenAttachmentByRef',
  \ 'bitwardenFields',
  \ 'bitwardenSecrets'
  \ ]
let s:dashlaneKeywords = [
  \ 'dashlaneNote',
  \ 'dashlanePassword'
  \ ]
let s:dopplerKeywords = [
  \ 'doppler',
  \ 'dopplerProjectJson'
  \ ]
let s:ejsonKeywords = [
  \ 'ejsonDecrypt',
  \ 'ejsonDecryptWithKey'
  \ ]
let s:functionKeywords = [
  \ 'abortEmpty',
  \ 'comment',
  \ 'completion',
  \ 'decrypt',
  \ 'deleteValueAtPath',
  \ 'encrypt',
  \ 'ensureLinePrefix',
  \ 'eqFold',
  \ 'findExecutable',
  \ 'findExecutableOnce',
  \ 'fromIni',
  \ 'fromJson',
  \ 'fromJsonc',
  \ 'fromToml',
  \ 'fromYaml',
  \ 'getRedirectedURL',
  \ 'glob',
  \ 'hexDecode',
  \ 'hexEncode',
  \ 'include',
  \ 'includeTemplate',
  \ 'ioreg',
  \ 'isExecutable',
  \ 'joinPath',
  \ 'jq',
  \ 'lookPath',
  \ 'lstat',
  \ 'mozillaInstallHash',
  \ 'output',
  \ 'outputList',
  \ 'pruneEmptyDicts',
  \ 'quoteList',
  \ 'replaceAllRegex',
  \ 'setValueAtPath',
  \ 'stat',
  \ 'toIni',
  \ 'toPrettyJson',
  \ 'toString',
  \ 'toStrings',
  \ 'toToml',
  \ 'toYaml',
  \ 'warnf'
  \ ]
let s:githubKeywords = [
  \ 'githubKeys',
  \ 'githubLatestRelease',
  \ 'githubLatestReleaseAsset',
  \ 'githubLatestTag',
  \ 'githubRelease',
  \ 'githubReleaseAssetURL',
  \ 'githubReleases',
  \ 'githubTags'
  \ ]
let s:gopassKeywords = [
  \ 'gopass',
  \ 'gopassRaw'
  \ ]
let s:initKeywords = [
  \ 'exit',
  \ 'promptBool',
  \ 'promptBoolOnce',
  \ 'promptChoice',
  \ 'promptChoiceOne',
  \ 'promptInt',
  \ 'promptIntOnce',
  \ 'promptMultichoice',
  \ 'promptMultichoiceOnce',
  \ 'promptString',
  \ 'promptStringOnce',
  \ 'stdinIsATTY',
  \ 'writeToStdout'
  \ ]
let s:keepassKeywords = [
  \ 'keepassxc',
  \ 'keepassxcAttachment',
  \ 'keepassxcAttribute'
  \ ]
let s:keeperKeywords = [
  \ 'keeper',
  \ 'keeperDataFields',
  \ 'keeperFindPassword'
  \ ]
let s:keyringKeywords = [
  \ 'keyring'
  \ ]
let s:lastpassKeywords = [
  \ 'lastpass',
  \ 'lastpassRaw'
  \ ]
let s:passKeywords = [
  \ 'pass',
  \ 'passFields',
  \ 'passRaw'
  \ ]
let s:passholeKeywords = [
  \ 'passhole'
  \ ]
let s:secretKeywords = [
  \ 'secret',
  \ 'secretJSON'
  \ ]
let s:vaultKeywords = [
  \ 'vault'
  \ ]

unlet! b:current_syntax

source <sfile>:h/gotmpl.vim

" Combine all keywords in one line
let s:chezmoiTmplFunctionsCombined = flatten([
  \ s:onepasswordKeywords,
  \ s:awsKeywords,
  \ s:azureKeywords,
  \ s:bitwardenKeywords,
  \ s:dashlaneKeywords,
  \ s:dopplerKeywords,
  \ s:ejsonKeywords,
  \ s:functionKeywords,
  \ s:githubKeywords,
  \ s:gopassKeywords,
  \ s:initKeywords,
  \ s:keepassKeywords,
  \ s:keeperKeywords,
  \ s:keyringKeywords,
  \ s:lastpassKeywords,
  \ s:passKeywords,
  \ s:passholeKeywords,
  \ s:secretKeywords,
  \ s:vaultKeywords])

execute 'syn keyword chezmoiTmplFunctions contained ' . join(s:chezmoiTmplFunctionsCombined, ' ')

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
