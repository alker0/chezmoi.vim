<div align="center">
<h1><strong>chezmoi.vim</strong></h1>

<strong>This plugin adds the support for your editing dotfiles in <a href="https://github.com/twpayne/chezmoi">chezmoi</a> source path.</strong>
</div>

<br>

<div align="center"><p>Resolving a file that has <code>dot_</code> prefix</p>
<img src="https://user-images.githubusercontent.com/51204827/115167010-cdc88d80-a0f0-11eb-8678-97e4ced4f7cc.gif" height="400px">

<p>Highlighting a template file</p>
<img src="https://user-images.githubusercontent.com/51204827/115132449-1aea2800-a03b-11eb-91bf-ea523f6e56a0.png">
</div>

# Table of contents

- [Why](#why)
- [Features](#features)
- [Install](#install)
- [Usage](#usage)
- [License](#license)

# Why

[chezmoi](https://github.com/twpayne/chezmoi) makes it much easier for you to manage your dotfiles. However, most of text editors do not enable syntax highlighting correctly because chezmoi manages your files by using special file naming (e.g. `dot_bashrc`). This plugin solves this problem.

# Features

This plugin makes vim treat the files to be edited as follows:
* `dot_bashrc` => `.bashrc`
* `dot_config/git/private_config` => `.config/git/config`

Furthermore, **with keeping original highlighting**, this plugin applies highlighting for `go-template` to template files (e.g. `dot_vimrc.tmpl`).

# Install

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

# Usage

As always, just run this:
```sh
$ chezmoi edit ~/.bashrc
# or
$ chezmoi cd
$ vim dot_bashrc
```
This plugin resolves the special prefixes automatically therefore highlighting for bash is applied correctly.

If the file is chezmoi template, this plugin merge syntax highlighting as follows:
* `dot_vimrc.tmpl` => `vim` + `go-template`
* `.chezmoitemplates/foo.toml` => `toml` + `go-template`

# License
The MIT License but includes works of the BSD License.

See [LICENSE](LICENSE) and [vendor/vim-go/LICENSE](vendor/vim-go/LICENSE) for more details.
