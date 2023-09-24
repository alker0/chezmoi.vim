<div align="center">
<h1><strong>chezmoi.vim</strong></h1>

<strong>This plugin adds the support for your editing dotfiles in <a href="https://github.com/twpayne/chezmoi">chezmoi</a> source path.</strong>
</div>

<br>

<div align="center"><p>Highlight even a template file</p>
<img src="https://user-images.githubusercontent.com/51204827/147376940-f9c23c25-89da-4ad0-9b92-907266afa388.gif" alt="highlighting a template demo" height="400px">

</div>

# Table of contents

- [Why](#why)
- [Features](#features)
- [Install](#install)
- [Usage](#usage)
- [Options](#options)
- [FAQ](#faq)
- [License](#license)

# Why

[chezmoi](https://github.com/twpayne/chezmoi) makes it much easier for you to manage your dotfiles. `chezmoi` uses special file naming (e.g. `dot_bashrc`) but you get still a syntax highlighting support because `chezmoi edit` resolves special naming before passing files to your editor. However you miss a correct highlighting in the following cases:
- When you edit directly dotfiles without `chezmoi edit`, `vim` does not highlight it.
- If you use [template](https://www.chezmoi.io/user-guide/templating) files (the powerful feature of `chezmoi`), `vim` losses an original syntax highlighting

This plugin solves those problems.

# Features

This plugin makes vim treat the files to be edited as follows:
* `dot_bashrc` => `.bashrc`
* `dot_config/git/private_config` => `.config/git/config`

Furthermore, **with keeping original highlighting**, this plugin applies that of `go-template` to template files (e.g. `dot_vimrc.tmpl`), as shown in the demo image.

# Install

:warning: You must load this plugin before the following timings:
* Calling `filetype on`, `syntax enable` or `syntax on`
* Loading other plugins that include `filetype.vim`
* End of `vimrc`
* End of `init.vim` if you use neovim

However enabling the `g:chezmoi#use_tmp_buffer` experimental option makes you free from the above limitation (see the [Options section](#options) for more details).

If you use [Vim 8 packages](http://vimhelp.appspot.com/repeat.txt.html#packages):
```sh
$ git clone https://github.com/alker0/chezmoi.vim ~/.vim/pack/plugins/opt/chezmoi.vim
```
And then insert this line your `vimrc` with taking the above notes into consideration:
```vim
packadd chezmoi.vim
```

You can also use the favorite plugin manager but you must **not** load this plugin lazily for detecting filetype correctly. You also have to load `chezmoi.vim` earlier than others unless you enable the `g:chezmoi#use_tmp_buffer` option.

The [FAQ section](#faq) can help you to install in some case. If `chezmoi.vim` don't work for you, see there at first.

# Usage

As always, just run this:
```sh
$ chezmoi edit ~/.bashrc
# or
$ chezmoi cd
$ vim dot_bashrc
```
This plugin resolves the special prefixes automatically therefore highlighting for bash is applied correctly.

If the file is a chezmoi template, this plugin merges syntax highlighting as follows:
* `dot_vimrc.tmpl` => `vim` + `go-template`
* `.chezmoitemplates/foo.toml` => `toml` + `go-template`

# Options
| Flag                              | Default                                                  | Description                                            |
| --------------------------------- | -------------------------------------------------------- | ----------------------------------------------         |
| `g:chezmoi#_loaded`               | 0                                                        | Setting 1 before loading disables this plugin          |
| `g:chezmoi#detect_ignore_pattern` | \<empty string>                                          | Regex pattern of path for ignoring file type detection |
| `g:chezmoi#use_external`          | \<not set>                                               | If set, enables the use of the external chezmoi binary for various purposes. More advanced, but slower. See comments below for more details |
| `g:chezmoi#source_dir_path`       | The value returned by `chezmoi source-path` (if the use of external chezmoi is enabled) or `$XDG_DATA_HOME/chezmoi` or `$HOME/.local/share/chezmoi` | Source Directory managed by chezmoi |
| `g:chezmoi#use_tmp_buffer`        | 0 | (experimental) Setting 1 makes this plugin create and use temporary buffer for making builtin filetype detection override wrong filetype |

Note:
* To enable the use of the external chezmoi binary, set the `g:chezmoi#use_external` variable. This variable must be set in `.vimrc` file, before the plugin is sourced. The value must be either a valid path to the binary, or just the binary name, if it can be found in `$PATH`. Alternatively, the value can be set to 1, in which case the plugin will try to detect the binary name automatically. After the plugin is sourced, the value of this variable may change. It will contain either the full name of the chezmoi binary that is used, or empty if the external chezmoi can not be used for some reason.
* If you get some problem about ordering of filetype detection, try setting the `g:chezmoi#use_tmp_buffer` variable with `1`. The feature should make it working correctly with any ordering, via using temporary buffer for avoiding limitation of Vim/Neovim's builtin filetype detection. The builtin detection use `setfiletype` ex command that works only once per buffer, so if using only same buffer (that is current default behavior of this plugin), asking Vim to run builtin detection with resolved path works only before calling `setfiletype` with wrong filetype. But if this plugin creates and uses a new temporary buffer every detection, `setfiletype` works again so this plugin can get resolved filetype from builtin detection anytime.

# FAQ

- [How can I make it work even if my chezmoi source directory isn't the default path?](#faq-1)
- [How can I make it work with `lazy.nvim`?](#faq-2)
- [Can I use `nvim-treesitter` for my `chezmoi-template`?](#faq-3)

### <a id="faq-1"></a> How can I make it work even if my chezmoi source directory isn't the default path?

Specify `g:chezmoi#source_dir_path` with your source directory path for let the plugin know like this:
```vim
let g:chezmoi#source_dir_path = '/path/to/your/source/dir'
" or if your `vimrc` is `chezmoi-template`:
let g:chezmoi#source_dir_path = '{{ .chezmoi.sourceDir }}'
```

For tracking your changing source directory with the `chezmoi` config (e.g. `~/.config/chezmoi/chezmoi.config.toml`) even without synchronizing there with calling like `chezmoi apply`, you can enable `g:chezmoi#use_external` instead of the above. It makes the plugin get your source directory path by calling `chezmoi source-path` command but it can have a little performance cost. For example:
```vim
let g:chezmoi#use_external = 1
" or if your `chezmoi` binary isn't in your `$PATH` environment variable:
let g:chezmoi#use_external = '/path/to/your/chezmoi/binary'
" or if your `vimrc` is `chezmoi-template`:
let g:chezmoi#use_external = '{{ .chezmoi.executable }}'
```

### <a id="faq-2"></a> How can I make it work with `lazy.nvim`?

Add the plugin like this minimum example:
```lua
require('lazy').setup({
  -- ...other plugins

  {
    'alker0/chezmoi.vim',
    lazy = false,
    init = function()
      -- This option is required.
      vim.g['chezmoi#use_tmp_buffer'] = true
      -- add other options here if needed.
    end,
  },

  -- ...other plugins
})
```

Because the `g:chezmoi#use_tmp_buffer` option is required, you can insert `chezmoi.vim` anywhere without caring a ordering of plugins.

### <a id="faq-3"></a> Can I use `nvim-treesitter` for my `chezmoi-template`?

No, the plugin supports for `treesitter` only detecting filetype and highlighting your non-`chezmoi-template` file. When you edit a `chezmoi-template` file, you have to disable `treesitter` and have Vim builtin highlighting with support from `chezmoi.vim`.

```lua
require('nvim-treesitter.configs').setup({
  highlight = {
    disable = function()
      -- check if 'filetype' option includes 'chezmoitmpl'
      if string.find(vim.bo.filetype, 'chezmoitmpl') then
        return true
      end
    end,
  },
})
```

# License
The MIT License but includes works of the BSD License.

See [LICENSE](LICENSE) and [vendor/vim-go/LICENSE](vendor/vim-go/LICENSE) for more details.
