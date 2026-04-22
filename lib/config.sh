#!/usr/bin/env bash
# Paths and shared utilities

CCP_VERSION="0.1.3"
CCP_REPO="felipeadeildo/claude-code-profiles"

CCP_DIR="${CCP_DIR:-$HOME/.ccp}"
CCP_PROFILES_DIR="$CCP_DIR/profiles"
CCP_CONFIG="$CCP_DIR/config"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

ccp_init() {
    mkdir -p "$CCP_PROFILES_DIR"
    [[ ! -f "$CCP_CONFIG" ]] && echo "default=" > "$CCP_CONFIG"
}

ccp_profile_path() { echo "$CCP_PROFILES_DIR/$1.env"; }

ccp_profile_exists() { [[ -f "$(ccp_profile_path "$1")" ]]; }

ccp_get_default() {
    grep '^default=' "$CCP_CONFIG" 2>/dev/null | cut -d= -f2
}

err()  { echo -e "${RED}error:${RESET} $*" >&2; }
ok()   { echo -e "${GREEN}✓${RESET} $*"; }
info() { echo -e "${CYAN}→${RESET} $*"; }

# Load profile vars, expanding ~ in values
ccp_load_vars() {
    local profile_file
    profile_file="$(ccp_profile_path "$1")"
    grep -v '^\s*#' "$profile_file" | grep -v '^\s*$' | while IFS= read -r line; do
        local key val
        key="${line%%=*}"
        val="${line#*=}"
        val="${val/#\~/$HOME}"
        echo "$key=$val"
    done
}

mask_key() {
    local val="$1"
    [[ ${#val} -gt 8 ]] && echo "${val:0:4}...${val: -4}" || echo "****"
}
