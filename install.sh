#!/usr/bin/env bash
# Quick installer for ccp

set -e

INSTALL_DIR="${1:-$HOME/.local/bin}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect shell rc file
case "${SHELL##*/}" in
    zsh)  RC="$HOME/.zshrc" ;;
    fish) RC="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" ;;
    *)    RC="$HOME/.bashrc" ;;
esac

echo "Installing ccp to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/ccp-lib"

cp -r "$SCRIPT_DIR/lib" "$INSTALL_DIR/ccp-lib"
sed "s|lib/config.sh|ccp-lib/config.sh|; s|lib/commands.sh|ccp-lib/commands.sh|" \
    "$SCRIPT_DIR/ccp.sh" > "$INSTALL_DIR/ccp"
chmod +x "$INSTALL_DIR/ccp"

# Add source line to shell rc if missing
SOURCE_LINE="source \"$INSTALL_DIR/ccp\""
if ! grep -qF "$SOURCE_LINE" "$RC" 2>/dev/null; then
    echo "" >> "$RC"
    echo "# ccp - Claude Code Profiles" >> "$RC"
    echo "$SOURCE_LINE" >> "$RC"
    echo "Added to $RC"
fi

echo "Done. Run: source $RC"
