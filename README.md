<div align="center">
<h1><strong>chezmoi.vim</strong></h1>

<strong>This plugin adds support for editing your dotfiles in a <a href="https://github.com/twpayne/chezmoi">chezmoi</a> source directory.</strong>
</div>

<br>

<div align="center"><p>Highlighting even a template file</p>
<img src="https://user-images.githubusercontent.com/51204827/147376940-f9c23c25-89da-4ad0-9b92-907266afa388.gif" alt="highlighting a template demo" height="400px">

</div>

# Table of contents

- [Motivation](#motivation)
- [Features](#features)
- [Requirements](#requirements)
- [Install](#install)
- [Usage](#usage)
- [Options](#options)
- [FAQ](#faq)
- [Contributing](#contributing)
- [License](#license)

# Motivation

[chezmoi](https://github.com/twpayne/chezmoi) makes it much easier to manage your dotfiles. `chezmoi` uses special file naming (e.g. `dot_bashrc`), but you still get syntax highlighting support because `chezmoi edit` resolves the special naming before passing files to your editor. However, you lose correct highlighting in the following cases:
- When you edit dotfiles directly without `chezmoi edit`, `vim` does not highlight them.
- If you use [template](https://www.chezmoi.io/user-guide/templating) files (the powerful feature of `chezmoi`), `vim` loses the original syntax highlighting.

This plugin solves those problems.

# Features

This plugin makes `vim` treat the files you edit as their resolved targets, for example:
* `dot_bashrc` => `.bashrc`
* `dot_config/git/private_config` => `.config/git/config`

Furthermore, **while keeping the original highlighting**, this plugin layers `go-template` highlighting on top of template files (e.g. `dot_vimrc.tmpl`), as shown in the demo image.

Beyond plain source files, it also recognises chezmoi's special files and applies the right highlighting. A representative subset:

| Kind | Examples |
| --- | --- |
| Attribute prefixes | `private_`, `executable_`, `readonly_`, `encrypted_`, `literal_`, … (e.g. `private_dot_netrc` => `.netrc`) |
| Templates | any `*.tmpl` file, and everything under `.chezmoitemplates/` (base filetype **+** `chezmoitmpl`) |
| Config & data | `.chezmoi.<ext>.tmpl`, `.chezmoidata.<ext>`, files under `.chezmoidata/` |
| Externals | `.chezmoiexternal.<ext>`, files under `.chezmoiexternals/` |
| Ignore lists | `.chezmoiignore`, `.chezmoiremove` |

This is not an exhaustive list; the goal is to cover chezmoi's common naming conventions while keeping editing as seamless as possible.

# Requirements

* **Vim 8.2.2449 or later**, or **Neovim 0.6.0 or later.** Earlier versions lack some built-in functions the plugin depends on.

> [!NOTE]
> **Platforms.** Unix-like systems are the primary, tested target. Windows (native, WSL, Git Bash, MSYS2) is *expected* to work, but is supported on a best-effort basis **without guarantees** — see [the FAQ](#faq-4) for why. (The hardlink-based `chezmoi edit` detection is currently enabled on Unix only.)

# Install

> [!WARNING]
> You must load this plugin before any of the following:
> * Calling `filetype on`, `syntax enable` or `syntax on`
> * Loading other plugins that include `filetype.vim`
> * The end of your `vimrc`
> * The end of your `init.vim` if you use Neovim

However, enabling the experimental `g:chezmoi#use_tmp_buffer` option frees you from the limitation above (see the [Options section](#options) for more details).

You must **not** load this plugin lazily; otherwise filetype detection will not work correctly. Unless you enable `g:chezmoi#use_tmp_buffer`, you must also load `chezmoi.vim` earlier than other plugins.

The [FAQ section](#faq) can help with some installation cases. If `chezmoi.vim` doesn't work for you, check there first.

### [Vim 8 packages](http://vimhelp.appspot.com/repeat.txt.html#packages)

```sh
$ git clone https://github.com/alker0/chezmoi.vim ~/.vim/pack/plugins/opt/chezmoi.vim
```
Then add this line to your `vimrc`, keeping the notes above in mind:
```vim
packadd chezmoi.vim
```

### [vim-plug](https://github.com/junegunn/vim-plug)

List `chezmoi.vim` first so it loads before the other plugins, and do **not** add any lazy-loading keys (`on`, `for`):
```vim
call plug#begin()
Plug 'alker0/chezmoi.vim'
" ...other plugins
call plug#end()
```

### [dein.vim](https://github.com/Shougo/dein.vim)

```vim
call dein#add('alker0/chezmoi.vim')
```
Do **not** set `lazy`, `on_ft` or similar options. Because dein merges plugins and the load order is hard to control, enabling `g:chezmoi#use_tmp_buffer` (see below) is recommended.

### [mini.deps](https://github.com/echasnovski/mini.deps)

Set the required option and add the plugin inside `now()` so it is sourced during startup:
```lua
local add, now = MiniDeps.add, MiniDeps.now
now(function()
  -- This option is required.
  vim.g['chezmoi#use_tmp_buffer'] = true
  add('alker0/chezmoi.vim')
end)
```

### [lazy.nvim](https://github.com/folke/lazy.nvim)

See the [FAQ](#faq-2).

### [packer.nvim](https://github.com/wbthomason/packer.nvim) / [pckr.nvim](https://github.com/lewis6991/pckr.nvim)

`packer.nvim` is unmaintained; its successor is `pckr.nvim`. The declaration is the same for both. Set the required option in `setup`, which runs before the plugin loads:
```lua
use {
  'alker0/chezmoi.vim',
  setup = function()
    -- This option is required.
    vim.g['chezmoi#use_tmp_buffer'] = true
  end,
}
```

> [!TIP]
> For Neovim plugin managers, enabling `g:chezmoi#use_tmp_buffer` is the simplest way to avoid every load-ordering problem, because it removes the requirement to load `chezmoi.vim` before other plugins.

# Usage

As always, just run this:
```sh
$ chezmoi edit ~/.bashrc
# or
$ chezmoi cd
$ vim dot_bashrc
```
This plugin resolves the special prefixes automatically, so bash highlighting is applied correctly.

If the file is a chezmoi template, this plugin merges syntax highlighting as follows:
* `dot_vimrc.tmpl` => `vim` + `go-template`
* `.chezmoitemplates/foo.toml` => `toml` + `go-template`

# Options
| Flag                              | Default                                                  | Description                                            |
| --------------------------------- | -------------------------------------------------------- | ----------------------------------------------         |
| `g:chezmoi#_loaded`               | 0                                                        | Setting 1 before loading disables this plugin          |
| `g:chezmoi#detect_ignore_pattern` | \<empty string>                                          | Regex pattern; paths matching it are skipped during filetype detection (see the note below) |
| `g:chezmoi#use_external`          | \<not set>                                               | If set, enables the use of the external chezmoi binary for various purposes. More advanced, but slower. See the notes below for more details |
| `g:chezmoi#source_dir_path`       | The value returned by `chezmoi source-path` (if the use of external chezmoi is enabled) or `$XDG_DATA_HOME/chezmoi` or `$HOME/.local/share/chezmoi` | Source directory managed by chezmoi |
| `g:chezmoi#use_tmp_buffer`        | 0 | (experimental) Setting 1 makes this plugin create and use a temporary buffer so that builtin filetype detection can override a wrong filetype |

Note:
* `g:chezmoi#detect_ignore_pattern` is an intentional **escape hatch**. The files this plugin hooks into live in your dotfiles repository, which may contain sensitive information, so a misdetection or misbehaviour could cause a serious incident. This option lets you turn detection off for arbitrary paths at any time — keep it in mind as a safety valve if the plugin ever interferes with a file you care about.

  The value is a **Vim regular expression** (a string, in Vim's default "magic" syntax — not a glob and not PCRE). It is tested against each file's **absolute path**, **case-sensitively** (`=~#`); if the pattern matches, detection is skipped for that file. For example:
  ```vim
  " Skip detection for everything under a directory named `secret`.
  let g:chezmoi#detect_ignore_pattern = '/secret/'

  " Skip a specific file (`.` matches any character, so escape it as `\.`).
  let g:chezmoi#detect_ignore_pattern = '/dot_netrc\.tmpl$'

  " Combine multiple patterns with `\|` (alternation).
  let g:chezmoi#detect_ignore_pattern = '/secret/\|/private_dot_ssh/'
  ```
  Leave it unset (rather than setting it to an empty string) when you don't need it: an empty pattern reuses Vim's last search pattern, which can match unexpectedly.
* To enable the use of the external chezmoi binary, set the `g:chezmoi#use_external` variable. This variable must be set in your `.vimrc` file, before the plugin is sourced. The value must be either a valid path to the binary, or just the binary name if it can be found in `$PATH`. Alternatively, the value can be set to 1, in which case the plugin will try to detect the binary name automatically. After the plugin is sourced, the value of this variable may change. It will contain either the full name of the chezmoi binary that is used, or empty if the external chezmoi cannot be used for some reason.
* If you have a problem with the ordering of filetype detection, try setting the `g:chezmoi#use_tmp_buffer` variable to `1`. This feature should make it work correctly with any ordering, by using a temporary buffer to avoid a limitation of Vim/Neovim's builtin filetype detection. The builtin detection uses the `setfiletype` ex command, which works only once per buffer; so if only the same buffer is used (the current default behaviour of this plugin), asking Vim to run builtin detection with the resolved path works only before `setfiletype` is called with a wrong filetype. But if this plugin creates and uses a new temporary buffer for every detection, `setfiletype` works again, so this plugin can get the resolved filetype from builtin detection at any time.

# FAQ

- [How can I make it work even if my chezmoi source directory isn't the default path?](#faq-1)
- [How can I make it work with `lazy.nvim`?](#faq-2)
- [Can I use `nvim-treesitter` for my `chezmoi-template`?](#faq-3)
- [Why is Windows support difficult?](#faq-4)

### <a id="faq-1"></a> How can I make it work even if my chezmoi source directory isn't the default path?

Set `g:chezmoi#source_dir_path` to your source directory path to let the plugin know, like this:
```vim
let g:chezmoi#source_dir_path = '/path/to/your/source/dir'
" or if your `vimrc` is a `chezmoi-template`:
let g:chezmoi#source_dir_path = '{{ .chezmoi.sourceDir }}'
```

To keep up with a source directory that you change through the `chezmoi` config (e.g. `~/.config/chezmoi/chezmoi.config.toml`) — even without synchronising it via a command like `chezmoi apply` — you can enable `g:chezmoi#use_external` instead of the above. It makes the plugin obtain your source directory path by calling the `chezmoi source-path` command, at a small performance cost. For example:
```vim
let g:chezmoi#use_external = 1
" or if your `chezmoi` binary isn't in your `$PATH` environment variable:
let g:chezmoi#use_external = '/path/to/your/chezmoi/binary'
" or if your `vimrc` is a `chezmoi-template`:
let g:chezmoi#use_external = '{{ .chezmoi.executable }}'
```

### <a id="faq-2"></a> How can I make it work with `lazy.nvim`?

Add the plugin like this minimal example:
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

Because the `g:chezmoi#use_tmp_buffer` option is required here, you can place `chezmoi.vim` anywhere without worrying about plugin ordering.

### <a id="faq-3"></a> Can I use `nvim-treesitter` for my `chezmoi-template`?

No. For `treesitter`, the plugin only supports filetype detection and highlighting of your non-`chezmoi-template` files. When you edit a `chezmoi-template` file, you have to disable `treesitter` and rely on Vim's builtin highlighting together with the support from `chezmoi.vim`.

```lua
require('nvim-treesitter.configs').setup({
  highlight = {
    disable = function()
      -- check if the 'filetype' option includes 'chezmoitmpl'
      if string.find(vim.bo.filetype, 'chezmoitmpl') then
        return true
      end
    end,
  },
})
```

### <a id="faq-4"></a> Why is Windows support difficult?

The plugin should work on Windows, but the surrounding ecosystem makes it hard to promise. Windows comes in several flavours that behave differently — native Windows, WSL, Git Bash and MSYS2 — and on top of that the plugin manager, the shell and the `chezmoi` binary itself can each differ in subtle ways (for example, path separators and how `chezmoi edit`'s temporary files are created). Covering every combination would require a test matrix that is impractical to maintain, so Windows is supported on a best-effort basis rather than guaranteed. If you hit a problem on Windows, the [`g:chezmoi#detect_ignore_pattern`](#options) escape hatch lets you disable detection for the affected paths.

# Contributing

Contributions are welcome! Adding newly released chezmoi template functions to
`syntax/chezmoitmpl.vim` is a great first contribution.

AI-assisted contributions are allowed under conditions (disclosure of the tool
and scope in the PR, human responsibility for understanding the code, and
verification in both Vim and Neovim). Please read [CONTRIBUTING.md](CONTRIBUTING.md)
before opening a pull request.

# License
The MIT License but includes works of the BSD License.

See [LICENSE](LICENSE) and [vendor/vim-go/LICENSE](vendor/vim-go/LICENSE) for more details.
