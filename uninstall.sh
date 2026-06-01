#!/usr/bin/env bash
# ccp uninstaller

set -e

CCP_HOME="${CCP_HOME:-$HOME/.ccp}"
BIN_DIR="$CCP_HOME/bin"
_CURRENT_SHELL="${SHELL##*/}"

case "$_CURRENT_SHELL" in
    zsh) RC="$HOME/.zshrc" ;;
    *)   RC="$HOME/.bashrc" ;;
esac

rm -rf "$BIN_DIR"
echo "Removed $BIN_DIR"

if [[ "$_CURRENT_SHELL" == "fish" ]]; then
    fish_fn="${XDG_CONFIG_HOME:-$HOME/.config}/fish/conf.d/ccp.fish"
    if [[ -f "$fish_fn" ]]; then
        rm "$fish_fn"
        echo "Removed $fish_fn"
    fi
elif [[ -f "$RC" ]]; then
    sed -i '/# ccp - Claude Code Profiles/d' "$RC"
    sed -i "\|source.*\.ccp/bin/ccp|d" "$RC"
    echo "Removed source line from $RC"
fi

echo
echo "ccp uninstalled."
echo "Your profiles in $CCP_HOME/profiles/ were not removed. Delete them manually if you want:"
echo "  rm -rf $CCP_HOME"
