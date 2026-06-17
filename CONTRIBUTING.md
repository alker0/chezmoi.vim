# Contributing to chezmoi.vim

Thanks for taking the time to contribute! This document covers two things:

1. The policy for **AI-assisted contributions**.
2. The procedure for **updating `syntax/chezmoitmpl.vim`** — the file that
   changes most often as chezmoi adds new template functions.

Please read the AI policy before opening a pull request, even for small
changes.

---

## AI-assisted contributions

The use of AI coding assistants (e.g. Claude Code, GitHub Copilot, ChatGPT,
Cursor) is **permitted, but conditionally**. The conditions below exist to
protect this project's unusual risk profile: `chezmoi.vim` hooks into Vim's
startup phase and is intentionally loaded *before* other plugins, so a defect
in the wrong place affects every Vim session — not just the file being edited.

### 1. You are responsible for the code you submit

Regardless of how code is produced, **the human author owns it**. By opening a
pull request you confirm that you understand every line you are submitting and
can explain *why* it is written that way. "The AI wrote it" is never an
acceptable answer to a review question.

Because this project has no CI or automated test suite, verification is manual
and **mandatory**. Every pull request description must state that you have
tested the change in **both Vim and Neovim**. Reviewers will ask for the
filetypes/paths you exercised, so keep notes as you test.

### 2. Disclose AI use in the pull request

If any part of your contribution was generated or materially assisted by an AI
tool, state it in the **PR description**, including:

- **Which tool(s)** you used (e.g. "Claude Code", "Copilot").
- **The scope** of AI involvement — which files or which parts were
  AI-generated vs. hand-written.

A short note is enough, for example:

> AI usage: Claude Code generated the new keyword list in
> `syntax/chezmoitmpl.vim`; the rest is hand-written. Tested in Vim 9.1 and
> Neovim 0.10.

This lets reviewers know where to focus their attention.

### 3. What AI may touch, and how carefully

The level of scrutiny depends on *where* the change lands. Find your change in
the table below.

| Area | AI allowed? | Required conditions |
| --- | --- | --- |
| **Core / startup logic** — `filetype.vim`, `autoload/chezmoi/*.vim` | Yes | You must understand **every line** and verify the change in **both Vim and Neovim**. These run on Vim startup, before other plugins, so the blast radius of a bug is large. Hold AI output here to the same bar as code you wrote yourself. |
| **`vendor/`** (e.g. `vendor/vim-go/`) | **No — changes prohibited in principle** | This directory contains third-party, BSD-licensed code. Do not edit, refactor, or regenerate it with AI. If an upstream update is genuinely needed, raise an issue first. |
| **Everything else** — `syntax/chezmoitmpl.vim` keyword lists, docs, README | Yes | Disclosure (§2) and understanding/verification (§1) still apply, but these areas carry lower risk. Keyword additions are the most AI- and automation-friendly contributions. |

### 4. Copyright and licensing

This project is MIT-licensed and bundles BSD-licensed work under `vendor/`
(see [`LICENSE`](LICENSE) and
[`vendor/vim-go/LICENSE`](vendor/vim-go/LICENSE)).

AI models can reproduce copyrighted code verbatim from their training data. By
submitting AI-assisted code you confirm, to the best of your knowledge, that
it:

- is **not a verbatim copy** of a third party's copyrighted work, and
- is **compatible with this project's MIT license** (and does not introduce
  code under an incompatible license).

If you are unsure about the origin of a non-trivial AI-generated block, do not
submit it.

---

## Editor compatibility

The plugin targets **Vim 8.2.2449+** and **Neovim 0.6.0+**. This baseline is a
deliberate trade-off, not an accident — the plugin intentionally avoids some
newer conveniences (for example, it works around `++once`, added in Vim
8.1.1113, with an `augroup`) to keep the floor as low as is practical.

Today that floor is set by two built-ins:

| Built-in | Introduced | Used in |
| --- | --- | --- |
| `trim({text}, {mask}, {dir})` — the third `{dir}` argument | Vim 8.2.1042 | `filetype.vim` (stripping trailing path delimiters / CR-LF) |
| `flatten()` | Vim 8.2.2449 / Neovim 0.6.0 | `syntax/chezmoitmpl.vim` (combining keyword lists) |

When contributing to the core or syntax files, please:

- **Avoid raising the floor** without a clear reason. Prefer functions and
  syntax that already work on the versions above. If a change genuinely needs a
  newer built-in, call it out in the PR so the requirement can be discussed and
  the README/`filetype.vim` note updated together.
- **Lowering the floor is welcome** if it is clean. Both built-ins above can be
  replaced (e.g. `trim(..., {dir})` with a `substitute()`, `flatten()` with
  `split()`/`map()`); if you do this, update the comment in `filetype.vim` and
  the requirement in the README to match.

## Updating `syntax/chezmoitmpl.vim`

`syntax/chezmoitmpl.vim` highlights chezmoi's own template functions on top of
the go-template base. chezmoi adds new template functions regularly, so this
file needs frequent, mechanical updates — a good first contribution.

### How the file is organized

Functions are grouped into per-category lists that mirror chezmoi's
[template functions reference](https://www.chezmoi.io/reference/templates/functions/),
for example `s:functionKeywords`, `s:githubKeywords`, `s:onepasswordKeywords`,
`s:vaultKeywords`. Every list is flattened together in the
`flatten([...])` call and registered as the `chezmoiTmplFunctions` keyword
group, which is linked to the `Function` highlight group.

### Adding a new function

1. Confirm the function exists in chezmoi's official
   [template functions reference](https://www.chezmoi.io/reference/templates/functions/).
2. Add its name to the **appropriate category list**, keeping the list in
   alphabetical order to match the existing style.
3. If the function belongs to a **new category** (e.g. a newly supported
   secret manager), create a new `s:<name>Keywords` list and add it to the
   `flatten([...])` call alongside the others.
4. Verify the highlighting (see below).

### Verifying your change

Open a chezmoi template that uses the function and confirm it is highlighted as
a function inside `{{ ... }}`, for example a `dot_file.tmpl` containing the new
call.

You can also smoke-test that the syntax file loads without errors in both
editors from the repository root:

```sh
# Vim
vim -u NONE -N --not-a-term -es \
  -c 'set rtp^=.' -c 'syntax on' \
  -c 'runtime syntax/chezmoitmpl.vim' -c 'qa!' && echo OK

# Neovim
nvim -u NONE -N --headless \
  -c 'set rtp^=.' -c 'syntax on' \
  -c 'runtime syntax/chezmoitmpl.vim' -c 'qa!' && echo OK
```

---

## Pull request checklist

Before you open a PR, make sure you can tick every box:

- [ ] I understand every line I am submitting and can explain it.
- [ ] I tested the change in **both Vim and Neovim**, and said so in the PR
      description.
- [ ] If I used an AI tool, I disclosed the tool and the scope of its use.
- [ ] I did not modify `vendor/`.
- [ ] Any AI-assisted code is not a verbatim copy of third-party work and is
      MIT-compatible.

Thanks again for contributing!
