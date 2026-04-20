#!/usr/bin/env bash
# ccp commands, sourced by ccp.sh

cmd_list() {
    ccp_init
    local default profiles=()
    default="$(ccp_get_default)"

    while IFS= read -r f; do
        profiles+=("$(basename "$f" .env)")
    done < <(find "$CCP_PROFILES_DIR" -name '*.env' | sort)

    if [[ ${#profiles[@]} -eq 0 ]]; then
        echo -e "${DIM}No profiles yet. Run: ccp new <name>${RESET}"
        return
    fi

    echo
    for p in "${profiles[@]}"; do
        local marker="  " extra=""
        [[ "$p" == "$default" ]] && marker="${GREEN}* ${RESET}" && extra=" ${DIM}(default)${RESET}"

        local base_url
        base_url=$(grep '^ANTHROPIC_BASE_URL=' "$(ccp_profile_path "$p")" 2>/dev/null | cut -d= -f2-)
        [[ -n "$base_url" ]] && extra="$extra ${DIM}[$base_url]${RESET}"

        echo -e "  ${marker}${BOLD}${p}${RESET}${extra}"
    done
    echo
}

cmd_new() {
    ccp_init
    local name="$1"
    [[ -z "$name" ]] && { printf "Profile name: "; read -r name; }
    [[ -z "$name" ]] && { err "Name cannot be empty."; return 1; }

    if ccp_profile_exists "$name"; then
        err "Profile '$name' already exists. Use: ccp edit $name"
        return 1
    fi

    local path
    path="$(ccp_profile_path "$name")"

    echo -e "\n${BOLD}Creating profile '$name'${RESET}"
    echo -e "${DIM}Press Enter to leave blank (system default will be used)${RESET}\n"

    printf "Claude config dir ${DIM}(e.g. ~/.claude-work)${RESET}: "
    read -r config_dir

    echo -e "\n${DIM}Popular providers:${RESET}"
    echo -e "  ${DIM}1) Anthropic (default)     uses ANTHROPIC_API_KEY${RESET}"
    echo -e "  ${DIM}2) OpenRouter              uses ANTHROPIC_API_KEY${RESET}"
    echo -e "  ${DIM}3) z.ai (GLM)              uses ANTHROPIC_AUTH_TOKEN${RESET}"
    echo -e "  ${DIM}4) Kimi (Moonshot)         uses ANTHROPIC_AUTH_TOKEN${RESET}"
    echo -e "  ${DIM}5) DeepSeek                uses ANTHROPIC_AUTH_TOKEN${RESET}"
    echo -e "  ${DIM}6) Ollama (local)          no key needed${RESET}"
    echo -e "  ${DIM}7) Other (enter URL)${RESET}"
    printf "\nProvider ${DIM}[1-7 or URL]${RESET}: "
    read -r provider_input

    local base_url="" auth_var=""
    case "$provider_input" in
        1|"") auth_var="ANTHROPIC_API_KEY" ;;
        2) base_url="https://openrouter.ai/api";        auth_var="ANTHROPIC_API_KEY" ;;
        3) base_url="https://api.z.ai/api/anthropic";   auth_var="ANTHROPIC_AUTH_TOKEN" ;;
        4) base_url="https://api.moonshot.ai/anthropic"; auth_var="ANTHROPIC_AUTH_TOKEN" ;;
        5) base_url="https://api.deepseek.com/anthropic"; auth_var="ANTHROPIC_AUTH_TOKEN" ;;
        6) base_url="http://localhost:11434";            auth_var="ollama" ;;
        *) [[ "$provider_input" == http* ]] && base_url="$provider_input"; auth_var="ANTHROPIC_API_KEY" ;;
    esac

    local api_key="" auth_token=""
    if [[ "$auth_var" == "ollama" ]]; then
        # Ollama needs empty API key and a fixed auth token
        api_key=""
        auth_token="ollama"
    elif [[ "$auth_var" == "ANTHROPIC_AUTH_TOKEN" ]]; then
        printf "\nAuth token ${DIM}(ANTHROPIC_AUTH_TOKEN, leave blank to set later)${RESET}: "
        read -rs auth_token; echo
    else
        printf "\nAPI key ${DIM}(ANTHROPIC_API_KEY, leave blank to use system key)${RESET}: "
        read -rs api_key; echo
    fi

    echo -e "\n${DIM}Model mapping (optional): maps Claude model names to provider models.${RESET}"
    echo -e "${DIM}Useful for providers like z.ai, Kimi, DeepSeek. Empty line to skip.${RESET}"
    printf "  Opus model   ${DIM}(ANTHROPIC_DEFAULT_OPUS_MODEL)${RESET}: "
    read -r model_opus
    printf "  Sonnet model ${DIM}(ANTHROPIC_DEFAULT_SONNET_MODEL)${RESET}: "
    read -r model_sonnet
    printf "  Haiku model  ${DIM}(ANTHROPIC_DEFAULT_HAIKU_MODEL)${RESET}: "
    read -r model_haiku

    local extra_vars=()
    echo -e "\n${DIM}Extra env vars? Empty line to finish.${RESET}"
    while true; do
        printf "  VAR=value: "
        read -r line
        [[ -z "$line" ]] && break
        extra_vars+=("$line")
    done

    {
        echo "# Profile: $name"
        echo "# Created: $(date '+%Y-%m-%d %H:%M')"
        echo
        [[ -n "$config_dir"    ]] && echo "CLAUDE_CONFIG_DIR=$config_dir"
        [[ -n "$base_url"      ]] && echo "ANTHROPIC_BASE_URL=$base_url"
        [[ "$auth_var" == "ollama" ]] && echo "ANTHROPIC_API_KEY=" && echo "ANTHROPIC_AUTH_TOKEN=ollama"
        [[ "$auth_var" == "ANTHROPIC_API_KEY"    && -n "$api_key"    ]] && echo "ANTHROPIC_API_KEY=$api_key"
        [[ "$auth_var" == "ANTHROPIC_AUTH_TOKEN" && -n "$auth_token" ]] && echo "ANTHROPIC_AUTH_TOKEN=$auth_token"
        [[ -n "$model_opus"    ]] && echo "ANTHROPIC_DEFAULT_OPUS_MODEL=$model_opus"
        [[ -n "$model_sonnet"  ]] && echo "ANTHROPIC_DEFAULT_SONNET_MODEL=$model_sonnet"
        [[ -n "$model_haiku"   ]] && echo "ANTHROPIC_DEFAULT_HAIKU_MODEL=$model_haiku"
        for v in "${extra_vars[@]}"; do echo "$v"; done
    } > "$path"

    ok "Profile '$name' created at $path"

    printf "\nSet as default? ${DIM}[y/N]${RESET}: "
    read -r ans
    [[ "$ans" =~ ^[yY]$ ]] && cmd_default "$name"
    echo
}

cmd_edit() {
    [[ -z "$1" ]] && { err "Usage: ccp edit <name>"; return 1; }
    ccp_profile_exists "$1" || { err "Profile '$1' not found."; return 1; }
    "${VISUAL:-${EDITOR:-vi}}" "$(ccp_profile_path "$1")"
}

cmd_show() {
    [[ -z "$1" ]] && { err "Usage: ccp show <name>"; return 1; }
    ccp_profile_exists "$1" || { err "Profile '$1' not found."; return 1; }

    echo -e "\n${BOLD}Profile: $1${RESET}\n"
    while IFS= read -r line; do
        if [[ "$line" =~ ^# ]] || [[ -z "$line" ]]; then
            echo -e "  ${DIM}${line}${RESET}"
        elif [[ "$line" =~ (API_KEY|AUTH_TOKEN) ]]; then
            local key val
            key="${line%%=*}"; val="${line#*=}"
            echo -e "  ${YELLOW}${key}${RESET}=${DIM}$(mask_key "$val")${RESET}"
        else
            echo -e "  ${YELLOW}${line%%=*}${RESET}=${GREEN}${line#*=}${RESET}"
        fi
    done < "$(ccp_profile_path "$1")"
    echo
}

cmd_remove() {
    [[ -z "$1" ]] && { err "Usage: ccp remove <name>"; return 1; }
    ccp_profile_exists "$1" || { err "Profile '$1' not found."; return 1; }

    printf "Remove profile '$1'? ${DIM}[y/N]${RESET}: "
    read -r ans
    if [[ "$ans" =~ ^[yY]$ ]]; then
        rm "$(ccp_profile_path "$1")"
        [[ "$(ccp_get_default)" == "$1" ]] && sed -i 's/^default=.*/default=/' "$CCP_CONFIG"
        ok "Profile '$1' removed."
    else
        echo "Cancelled."
    fi
}

# Must be called in the current shell (not a subshell) for exports to stick.
cmd_use() {
    local name="${1:-$(ccp_get_default)}"
    [[ -z "$name" ]] && { err "No profile specified and no default set."; return 1; }
    ccp_profile_exists "$name" || { err "Profile '$name' not found."; return 1; }

    while IFS= read -r line; do
        local key val
        key="${line%%=*}"; val="${line#*=}"
        val="${val/#\~/$HOME}"
        export "$key=$val"
        local display
        [[ "$key" == *API_KEY* || "$key" == *AUTH_TOKEN* ]] && display="$(mask_key "$val")" || display="$val"
        info "export ${key}=${DIM}${display}${RESET}"
    done < <(ccp_load_vars "$name")

    ok "Profile '$name' active in current session."
}

cmd_run() {
    local name="$1"; shift
    [[ -z "$name" ]] && { err "Usage: ccp run <name> [command...]"; return 1; }
    ccp_profile_exists "$name" || { err "Profile '$name' not found."; return 1; }

    local env_args=()
    while IFS= read -r line; do
        local key val
        key="${line%%=*}"; val="${line#*=}"
        val="${val/#\~/$HOME}"
        env_args+=("$key=$val")
    done < <(ccp_load_vars "$name")

    if [[ $# -eq 0 ]]; then
        env "${env_args[@]}" claude
    else
        env "${env_args[@]}" "$@"
    fi
}

cmd_default() {
    if [[ -z "$1" ]]; then
        local cur
        cur="$(ccp_get_default)"
        [[ -z "$cur" ]] && echo -e "${DIM}No default profile set.${RESET}" || echo -e "Default: ${BOLD}${cur}${RESET}"
        return
    fi
    ccp_profile_exists "$1" || { err "Profile '$1' not found."; return 1; }
    sed -i "s/^default=.*/default=$1/" "$CCP_CONFIG"
    ok "Default set to '$1'."
}

cmd_doctor() {
    ccp_init
    echo -e "\n${BOLD}ccp doctor${RESET}\n"

    for dep in claude env grep sed; do
        command -v "$dep" &>/dev/null \
            && echo -e "  ${GREEN}✓${RESET} $dep" \
            || echo -e "  ${RED}✗${RESET} $dep not found"
    done
    echo

    local profiles=()
    while IFS= read -r f; do
        profiles+=("$(basename "$f" .env)")
    done < <(find "$CCP_PROFILES_DIR" -name '*.env' | sort)

    if [[ ${#profiles[@]} -eq 0 ]]; then
        echo -e "${DIM}  No profiles to validate.${RESET}"
    else
        for p in "${profiles[@]}"; do
            local path issues=()
            path="$(ccp_profile_path "$p")"

            local cdir
            cdir=$(grep '^CLAUDE_CONFIG_DIR=' "$path" 2>/dev/null | cut -d= -f2-)
            cdir="${cdir/#\~/$HOME}"
            [[ -n "$cdir" && ! -d "$cdir" ]] && issues+=("CLAUDE_CONFIG_DIR '$cdir' does not exist (will be created by Claude Code)")

            if [[ ${#issues[@]} -eq 0 ]]; then
                local base_url
                base_url=$(grep '^ANTHROPIC_BASE_URL=' "$path" 2>/dev/null | cut -d= -f2-)
                printf "  ${GREEN}✓${RESET} %-20s" "$p"
                [[ -n "$base_url" ]] && printf " ${DIM}[$base_url]${RESET}"
                echo
            else
                printf "  ${YELLOW}⚠${RESET} %-20s\n" "$p"
                for issue in "${issues[@]}"; do
                    echo -e "      ${DIM}→ $issue${RESET}"
                done
            fi
        done
    fi
    echo
}

cmd_help() {
    echo -e "
${BOLD}ccp${RESET} - Claude Code Profiles

${BOLD}Commands:${RESET}
  ${CYAN}ccp list${RESET}                        list all profiles
  ${CYAN}ccp new${RESET} <profile>               create a new profile (interactive)
  ${CYAN}ccp edit${RESET} <profile>              edit profile in \$EDITOR
  ${CYAN}ccp show${RESET} <profile>              show profile vars (API key masked)
  ${CYAN}ccp remove${RESET} <profile>            delete a profile
  ${CYAN}ccp use${RESET} <profile>               export profile vars into current shell
  ${CYAN}ccp run${RESET} <profile> <cmd...>      run a command with profile vars
  ${CYAN}ccp default${RESET} [profile]           get or set the default profile
  ${CYAN}ccp doctor${RESET}                      validate all profiles

${BOLD}Shorthand:${RESET}
  ${CYAN}ccp <profile>${RESET}                   launch claude with that profile's vars
  ${CYAN}ccp run <profile> <cmd...>${RESET}      run any other command with profile vars

  <profile> is always a name you created with 'ccp new'.
  It is never a built-in keyword.

${BOLD}Examples:${RESET}
  ccp work                            # launch claude as 'work'
  ccp openrouter                      # launch claude as 'openrouter'
  ccp run work python script.py       # run something else with 'work' vars

${BOLD}Config dir:${RESET} ${CCP_DIR}
"
}
