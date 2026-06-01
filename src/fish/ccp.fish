# ccp - Claude Code Profiles (fish wrapper)
#
# Installed to ~/.config/fish/conf.d/ccp.fish by the ccp installer.
# All commands except `ccp use` are delegated to the bash binary.
# `ccp use` is handled here so vars can be exported into the current shell.

function ccp
    set -l _bin "$HOME/.ccp/bin/ccp"
    set -l _cfg "$HOME/.ccp/bin/lib/config.sh"

    if not test -f "$_bin"
        printf '%serror:%s ccp not installed (expected %s)\n' \
            (set_color red) (set_color normal) "$_bin" >&2
        return 1
    end

    # `ccp use` must run in the current shell to export vars — fish can't source bash syntax
    if test (count $argv) -gt 0; and test "$argv[1]" = use
        set -l _profile
        if test (count $argv) -ge 2
            set _profile $argv[2]
        else
            set _profile (bash -c "source '$_cfg' && ccp_init && ccp_get_default" 2>/dev/null)
        end

        if test -z "$_profile"
            printf '%serror:%s No profile specified and no default set.\n' \
                (set_color red) (set_color normal) >&2
            return 1
        end

        set -l _ok (bash -c "source '$_cfg' && ccp_profile_exists '$_profile' && echo yes" 2>/dev/null)
        if test "$_ok" != yes
            printf '%serror:%s Profile \'%s\' not found.\n' \
                (set_color red) (set_color normal) "$_profile" >&2
            return 1
        end

        # Capture KEY=VALUE lines (command substitution splits on newlines — no pipeline subshell)
        set -l _lines (bash -c "source '$_cfg' && ccp_load_vars '$_profile'" 2>/dev/null)
        for _line in $_lines
            set -l _key (string split -m 1 '=' -- $_line)[1]
            set -l _val (string split -m 1 '=' -- $_line)[2]
            set -gx $_key $_val
            set -l _display $_val
            if string match -q '*API_KEY*' $_key; or string match -q '*AUTH_TOKEN*' $_key
                if test (string length -- $_val) -gt 8
                    set _display (string sub -l 4 -- $_val)...(string sub --start=-4 -- $_val)
                else
                    set _display '****'
                end
            end
            printf '%s→%s export %s=%s%s%s\n' \
                (set_color cyan) (set_color normal) \
                $_key (set_color brblack) $_display (set_color normal)
        end
        printf '%s✓%s Profile \'%s\' active in current session.\n' \
            (set_color green) (set_color normal) $_profile
        return 0
    end

    # Everything else: delegate to bash (runs in subshell, which is fine)
    bash "$_bin" $argv
end
