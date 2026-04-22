#!/usr/bin/env bash
# ccp uninstaller

set -e

CCP_HOME="${CCP_HOME:-$HOME/.ccp}"
BIN_DIR="$CCP_HOME/bin"

case "${SHELL##*/}" in
    zsh)  RC="$HOME/.zshrc" ;;
    fish) RC="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" ;;
    *)    RC="$HOME/.bashrc" ;;
esac

rm -rf "$BIN_DIR"
echo "Removed $BIN_DIR"

if [[ -f "$RC" ]]; then
    sed -i '/# ccp - Claude Code Profiles/d' "$RC"
    sed -i "\|source.*\.ccp/bin/ccp|d" "$RC"
    echo "Removed source line from $RC"
fi

echo
echo "ccp uninstalled."
echo "Your profiles in $CCP_HOME/profiles/ were not removed. Delete them manually if you want:"
echo "  rm -rf $CCP_HOME"
