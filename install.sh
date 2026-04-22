#!/usr/bin/env bash
# Quick installer for ccp
#
# Usage (remote):  curl -fsSL https://raw.githubusercontent.com/felipeadeildo/claude-code-profiles/main/install.sh | bash
# Usage (local):   bash install.sh [install_dir]
# Usage (update):  bash install.sh [install_dir] --src <extracted_dir>

set -e

INSTALL_DIR="${1:-$HOME/.local/bin}"
REPO="felipeadeildo/claude-code-profiles"
SRC_DIR=""

shift 2>/dev/null || true
while [[ $# -gt 0 ]]; do
    case "$1" in
        --src) SRC_DIR="$2"; shift 2 ;;
        *) shift ;;
    esac
done

case "${SHELL##*/}" in
    zsh)  RC="$HOME/.zshrc" ;;
    fish) RC="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" ;;
    *)    RC="$HOME/.bashrc" ;;
esac

_install_from_dir() {
    local src="$1"
    cp -r "$src/lib/." "$INSTALL_DIR/ccp-lib"
    sed "s|lib/config.sh|ccp-lib/config.sh|; s|lib/commands.sh|ccp-lib/commands.sh|" \
        "$src/ccp.sh" > "$INSTALL_DIR/ccp"
}

echo "Installing ccp to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR/ccp-lib"

if [[ -n "$SRC_DIR" ]]; then
    _install_from_dir "$SRC_DIR"
else
    local_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd)" || local_dir=""
    if [[ -f "$local_dir/ccp.sh" && -d "$local_dir/lib" ]]; then
        _install_from_dir "$local_dir"
    else
        # Download latest release zip
        api_url="https://api.github.com/repos/${REPO}/releases/latest"
        latest=$(curl -sf "$api_url" | grep '"tag_name"' | cut -d'"' -f4)
        [[ -z "$latest" ]] && { echo "error: could not reach GitHub" >&2; exit 1; }

        zip_url="https://github.com/${REPO}/archive/refs/tags/${latest}.zip"
        tmp_dir="$(mktemp -d)"
        trap 'rm -rf "$tmp_dir"' EXIT

        echo "Downloading ${latest}..."
        curl -fsSL "$zip_url" -o "$tmp_dir/ccp.zip"
        unzip -q "$tmp_dir/ccp.zip" -d "$tmp_dir"

        extracted="$(ls -d "$tmp_dir"/claude-code-profiles-*/)"
        extracted="${extracted%/}"
        _install_from_dir "$extracted"
    fi
fi

chmod +x "$INSTALL_DIR/ccp"

SOURCE_LINE="source \"$INSTALL_DIR/ccp\""
if ! grep -qF "$SOURCE_LINE" "$RC" 2>/dev/null; then
    echo "" >> "$RC"
    echo "# ccp - Claude Code Profiles" >> "$RC"
    echo "$SOURCE_LINE" >> "$RC"
    echo "Added to $RC"
fi

echo "Done. Run: source $RC"
