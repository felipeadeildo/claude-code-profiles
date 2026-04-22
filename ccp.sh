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
    local default_profile
    default_profile="$(ccp_get_default)"
    local cmd="${1:-${default_profile:-help}}"
    shift 2>/dev/null || true

    case "$cmd" in
        list|ls)       _ccp_schedule_update_check; cmd_list ;;
        new|create)    _ccp_schedule_update_check; cmd_new "$@" ;;
        edit)          _ccp_schedule_update_check; cmd_edit "$@" ;;
        show|cat)      _ccp_schedule_update_check; cmd_show "$@" ;;
        remove|rm|del) _ccp_schedule_update_check; cmd_remove "$@" ;;
        use)           _ccp_schedule_update_check; cmd_use "$@" ;;
        run|exec)      _ccp_schedule_update_check; cmd_run "$@" ;;
        default)       _ccp_schedule_update_check; cmd_default "$@" ;;
        doctor)        _ccp_schedule_update_check; cmd_doctor ;;
        version|--version) cmd_version ;;
        update)           cmd_update ;;
        help|--help|-h)   cmd_help ;;
        *)
            if ccp_profile_exists "$cmd"; then
                _ccp_schedule_update_check
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
