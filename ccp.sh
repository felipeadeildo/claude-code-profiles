#!/usr/bin/env bash
# ccp - Claude Code Profiles
#
# Installation:
#   cp ccp.sh ~/.local/bin/ccp && chmod +x ~/.local/bin/ccp
#   echo 'source ~/.local/bin/ccp' >> ~/.bashrc   # or ~/.zshrc (required for `ccp use`)
#   source ~/.bashrc

_CCP_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"

source "$_CCP_SCRIPT_DIR/lib/config.sh"
source "$_CCP_SCRIPT_DIR/lib/commands.sh"

_ccp_main() {
    ccp_init
    _ccp_schedule_update_check
    local default_profile
    default_profile="$(ccp_get_default)"
    local cmd="${1:-${default_profile:-help}}"
    shift 2>/dev/null || true

    case "$cmd" in
        list|ls)       cmd_list ;;
        new|create)    cmd_new "$@" ;;
        edit)          cmd_edit "$@" ;;
        show|cat)      cmd_show "$@" ;;
        remove|rm|del) cmd_remove "$@" ;;
        use)           cmd_use "$@" ;;
        run|exec)      cmd_run "$@" ;;
        default)       cmd_default "$@" ;;
        doctor)           cmd_doctor ;;
        version|--version) cmd_version ;;
        update)           cmd_update ;;
        help|--help|-h)   cmd_help ;;
        *)
            if ccp_profile_exists "$cmd"; then
                cmd_run "$cmd" "$@"
            else
                err "Unknown command: '$cmd'"
                cmd_help
                return 1
            fi
            ;;
    esac
}

# When sourced: define ccp() so `ccp use` can export vars into the current shell.
# When executed directly: run as a regular script (use won't export to parent shell).
if [[ "${BASH_SOURCE[0]}" != "${0}" ]] || [[ -n "$ZSH_VERSION" && "$ZSH_EVAL_CONTEXT" == *:file:* ]]; then
    ccp() { _ccp_main "$@"; }
else
    _ccp_main "$@"
fi
