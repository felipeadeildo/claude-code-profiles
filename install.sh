#!/usr/bin/env bash
# ccp installer
#
# Usage (curl):   curl -fsSL https://raw.githubusercontent.com/felipeadeildo/claude-code-profiles/main/install.sh | bash
# Usage (local):  bash install.sh

set -euo pipefail

CCP_HOME="${CCP_HOME:-$HOME/.ccp}"
BIN_DIR="$CCP_HOME/bin"
REPO="felipeadeildo/claude-code-profiles"

case "${SHELL##*/}" in
    zsh)  RC="$HOME/.zshrc" ;;
    fish) RC="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" ;;
    *)    RC="$HOME/.bashrc" ;;
esac

_install_from_repo_root() {
    local root="$1"
    mkdir -p "$BIN_DIR"
    cp -r "$root/src/lib" "$BIN_DIR/"
    cp "$root/src/ccp.sh" "$BIN_DIR/ccp"
    chmod +x "$BIN_DIR/ccp"
}

local_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd)" || local_dir=""

if [[ -d "$local_dir/src" ]]; then
    echo "Installing ccp from local source..."
    _install_from_repo_root "$local_dir"
else
    echo "Installing ccp..."
    api_url="https://api.github.com/repos/${REPO}/releases/latest"
    latest=$(curl -sf "$api_url" | grep '"tag_name"' | cut -d'"' -f4)
    [[ -z "$latest" ]] && { echo "error: could not reach GitHub" >&2; exit 1; }

    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' EXIT

    echo "Downloading ${latest}..."
    curl -fsSL "https://github.com/${REPO}/archive/refs/tags/${latest}.zip" \
        -o "$tmp_dir/ccp.zip"
    unzip -q "$tmp_dir/ccp.zip" -d "$tmp_dir"

    extracted=("$tmp_dir"/claude-code-profiles-*/)
    [[ -d "${extracted[0]}" ]] || { echo "error: extraction failed" >&2; exit 1; }
    _install_from_repo_root "${extracted[0]%/}"
fi

SOURCE_LINE="source \"$BIN_DIR/ccp\""
if ! grep -qF "$SOURCE_LINE" "$RC" 2>/dev/null; then
    printf '\n# ccp - Claude Code Profiles\n%s\n' "$SOURCE_LINE" >> "$RC"
    echo "Added source line to $RC"
fi

echo "Done. Run: source $RC"
