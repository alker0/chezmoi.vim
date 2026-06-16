#!/bin/bash
# SessionStart hook for chezmoi.vim
#
# Installs the tools required to develop and verify this Vim/Neovim plugin:
#   - neovim : the plugin targets both Vim and Neovim; some code paths
#              (e.g. the neovim#27914 workaround) can only be exercised on nvim.
#   - chezmoi: needed to verify the `g:chezmoi#use_external` integration and to
#              keep syntax/chezmoitmpl.vim's function list in sync with upstream.
#
# Vim itself is already present in the base image, so it is not installed here.
#
# Network notes for this environment (verified at authoring time):
#   - apt mirrors and api.github.com / get.chezmoi.io are NOT reachable.
#   - github.com release assets (releases/download/...) ARE reachable.
# Therefore we download pinned official release tarballs directly from GitHub.
set -euo pipefail

# Only run inside the Claude Code remote (web) environment.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Pinned versions (api.github.com is blocked, so "latest" cannot be queried).
NVIM_VERSION="v0.10.4"
CHEZMOI_VERSION="v2.52.3"

ARCH="$(uname -m)"
if [ "$ARCH" != "x86_64" ]; then
  echo "session-start: unsupported arch '$ARCH'; expected x86_64" >&2
  exit 1
fi

install_neovim() {
  if command -v nvim >/dev/null 2>&1; then
    echo "session-start: nvim already installed ($(nvim --version | head -1))"
    return 0
  fi

  local tarball="nvim-linux-x86_64.tar.gz"
  local url="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${tarball}"
  local tmp
  tmp="$(mktemp -d)"

  echo "session-start: installing neovim ${NVIM_VERSION} ..."
  curl -fsSL --retry 3 --retry-delay 2 -o "${tmp}/${tarball}" "$url"

  # Replace any previous extraction so this stays idempotent.
  rm -rf /opt/nvim
  mkdir -p /opt/nvim
  tar -xzf "${tmp}/${tarball}" -C /opt/nvim --strip-components=1
  ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

  rm -rf "$tmp"
  echo "session-start: nvim ready ($(nvim --version | head -1))"
}

install_chezmoi() {
  if command -v chezmoi >/dev/null 2>&1; then
    echo "session-start: chezmoi already installed ($(chezmoi --version))"
    return 0
  fi

  local ver="${CHEZMOI_VERSION#v}"
  local tarball="chezmoi_${ver}_linux_amd64.tar.gz"
  local url="https://github.com/twpayne/chezmoi/releases/download/${CHEZMOI_VERSION}/${tarball}"
  local tmp
  tmp="$(mktemp -d)"

  echo "session-start: installing chezmoi ${CHEZMOI_VERSION} ..."
  curl -fsSL --retry 3 --retry-delay 2 -o "${tmp}/${tarball}" "$url"
  tar -xzf "${tmp}/${tarball}" -C "$tmp" chezmoi
  install -m 0755 "${tmp}/chezmoi" /usr/local/bin/chezmoi

  rm -rf "$tmp"
  echo "session-start: chezmoi ready ($(chezmoi --version))"
}

install_neovim
install_chezmoi

echo "session-start: all tools ready"
