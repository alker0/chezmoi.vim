# chezmoi.vim

This plugin adds the support for your editing dotfiles in [chezmoi](https://github.com/twpayne/chezmoi) source path.

## Why

[chezmoi](https://github.com/twpayne/chezmoi) makes it much easier for you to manage your dotfiles. However, most of text editors do not enable syntax highlighting correctly because chezmoi manages your files by using special file naming (e.g. `dot_bashrc`). This plugin solves this problem.

## Features

This plugin makes vim treat the files to be edited as follows:
* `dot_bashrc` => `.bashrc`
* `dot_config/git/private_config` => `.config/git/config`

Furthermore, **with keeping original highlighting**, this plugin applyes `go-template`'s one to chezmoi's template files (e.g. `dot_vimrc.tmpl`).

## Install

:warning: Notes: You must load this plugin before the following timings:
* Calling `filetype on`, `syntax enable` or `syntax on`
* Loading other plugins that include `filetype.vim`
* End of `vimrc`
* End of `init.vim` if you use neovim

If you use [Vim 8 packages](http://vimhelp.appspot.com/repeat.txt.html#packages):
```sh
$ git clone https://github.com/alker0/chezmoi.vim ~/.vim/pack/plugins/opt/chezmoi.vim
```
And then instert this line your `vimrc` with taking the above notes into consideration:
```vim
packadd chezmoi.vim
```

You can also use the favorite plugin manager, in that case, make your plugin manager load this plugin earlier than others. You must **not** load this plugin lazily.

## Usege

As always, just run this:
```sh
$ chezmoi edit ~/.bashrc
# or
$ chezmoi cd
$ vim dot_bashrc
```
This plugin resolves the special prefixes automatically therefore `bash`'s highlighting is applied correctly.

If the file is chezmoi template, this plugin merge syntax highlighting as follows:
* `dot_vimrc.tmpl` => `vim` + `go template`
* `.chezmoitemplates/foo.toml` => `toml` + `go template`

## License
The MIT License but includes works of the BSD License.

See [LICENSE](LICENSE) and [vendor/vim-go/LICENSE](vendor/vim-go/LICENSE) for more details.
