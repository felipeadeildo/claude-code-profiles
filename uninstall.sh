#!/usr/bin/env bash
# Uninstaller for ccp

set -e

INSTALL_DIR="${1:-$HOME/.local/bin}"

# Detect shell rc file
case "${SHELL##*/}" in
    zsh)  RC="$HOME/.zshrc" ;;
    fish) RC="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" ;;
    *)    RC="$HOME/.bashrc" ;;
esac

# Remove installed files
rm -f "$INSTALL_DIR/ccp"
rm -rf "$INSTALL_DIR/ccp-lib"
echo "Removed $INSTALL_DIR/ccp and $INSTALL_DIR/ccp-lib"

# Remove source line from rc file
if [[ -f "$RC" ]] && grep -qF "ccp" "$RC"; then
    sed -i '/# ccp - Claude Code Profiles/d' "$RC"
    sed -i "\|source.*ccp|d" "$RC"
    echo "Removed source line from $RC"
fi

echo
echo "ccp uninstalled."
echo "Your profiles in ~/.ccp/ were not removed. Delete them manually if you want:"
echo "  rm -rf ~/.ccp"
