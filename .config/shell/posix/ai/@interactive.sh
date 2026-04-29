#!/usr/bin/env bash

export SAFEHOUSE_PROFILE_LOCAL_OVERRIDES="${SAFEHOUSE_PROFILE_LOCAL_OVERRIDES:-$HOME/.config/agent-safehouse/local-overrides.sb}"
export SAFEHOUSE_PROFILE_CARGO="${SAFEHOUSE_PROFILE_CARGO:-${XDG_CACHE_HOME:-$HOME/.cache}/agent-safehouse/cargo.sb}"
export SAFEHOUSE_PROFILE_CLAUDE="${SAFEHOUSE_PROFILE_CLAUDE:-$HOME/.config/agent-safehouse/claude.sb}"
export SAFEHOUSE_PROFILE_CODEX="${SAFEHOUSE_PROFILE_CODEX:-$HOME/.config/agent-safehouse/codex.sb}"
export SAFEHOUSE_PROFILE_CURSOR="${SAFEHOUSE_PROFILE_CURSOR:-$HOME/.config/agent-safehouse/cursor.sb}"
export SAFEHOUSE_PROFILE_GEMINI="${SAFEHOUSE_PROFILE_GEMINI:-$HOME/.config/agent-safehouse/gemini.sb}"
export SAFEHOUSE_PROFILE_NIX="${SAFEHOUSE_PROFILE_NIX:-$HOME/.config/agent-safehouse/nix.sb}"
export SAFEHOUSE_PROFILE_DOTNET="${SAFEHOUSE_PROFILE_DOTNET:-$HOME/.config/agent-safehouse/dotnet.sb}"
export SAFEHOUSE_PROFILE_DOCKER="${SAFEHOUSE_PROFILE_DOCKER:-$HOME/.config/agent-safehouse/docker.sb}"
SAFE_GITHUB_AUTH_PROVIDER="${SAFE_GITHUB_AUTH_PROVIDER:-github-auth-provider}"
SAFEHOUSE_APPEND_PROFILES_CARGO="${SAFEHOUSE_APPEND_PROFILES_CARGO:-$SAFEHOUSE_PROFILE_CARGO}"
SAFEHOUSE_APPEND_PROFILES_DEFAULT="${SAFEHOUSE_APPEND_PROFILES_DEFAULT:-$SAFEHOUSE_PROFILE_LOCAL_OVERRIDES}"
SAFEHOUSE_APPEND_PROFILES_CLAUDE="${SAFEHOUSE_APPEND_PROFILES_CLAUDE:-$SAFEHOUSE_PROFILE_CLAUDE}"
SAFEHOUSE_APPEND_PROFILES_CODEX="${SAFEHOUSE_APPEND_PROFILES_CODEX:-$SAFEHOUSE_PROFILE_CODEX}"
SAFEHOUSE_APPEND_PROFILES_CURSOR="${SAFEHOUSE_APPEND_PROFILES_CURSOR:-$SAFEHOUSE_PROFILE_CURSOR}"
SAFEHOUSE_APPEND_PROFILES_GEMINI="${SAFEHOUSE_APPEND_PROFILES_GEMINI:-$SAFEHOUSE_PROFILE_GEMINI}"
SAFEHOUSE_APPEND_PROFILES_NIX="${SAFEHOUSE_APPEND_PROFILES_NIX:-$SAFEHOUSE_PROFILE_NIX}"
SAFEHOUSE_APPEND_PROFILES_EXTRA="${SAFEHOUSE_APPEND_PROFILES_EXTRA:-}"
SAFEHOUSE_APPEND_PROFILES_CLAUDE_EXTRA="${SAFEHOUSE_APPEND_PROFILES_CLAUDE_EXTRA:-}"
SAFEHOUSE_APPEND_PROFILES_CODEX_EXTRA="${SAFEHOUSE_APPEND_PROFILES_CODEX_EXTRA:-}"
SAFEHOUSE_APPEND_PROFILES_CURSOR_EXTRA="${SAFEHOUSE_APPEND_PROFILES_CURSOR_EXTRA:-}"
SAFEHOUSE_APPEND_PROFILES_GEMINI_EXTRA="${SAFEHOUSE_APPEND_PROFILES_GEMINI_EXTRA:-}"
SAFEHOUSE_APPEND_PROFILES_NIX_EXTRA="${SAFEHOUSE_APPEND_PROFILES_NIX_EXTRA:-}"
SAFEHOUSE_APPEND_PROFILES_DOTNET_EXTRA="${SAFEHOUSE_APPEND_PROFILES_DOTNET_EXTRA:-}"
SAFEHOUSE_APPEND_PROFILES_DOCKER_EXTRA="${SAFEHOUSE_APPEND_PROFILES_DOCKER_EXTRA:-}"
WORK_BASE="$HOME/work"

safe_debug() {
    /usr/bin/log stream \
      --style compact \
      --predicate 'eventMessage CONTAINS "Sandbox:" AND eventMessage CONTAINS "deny("'
}

safe_join_profile_lists() {
    local joined="" profile_list

    for profile_list in "$@"; do
      [[ -z "$profile_list" ]] && continue
      joined+="${joined:+:}${profile_list}"
    done

    printf '%s\n' "$joined"
}

safe_append_profiles() {
    local profile_list
    local old_ifs
    local profile

    if [[ -n "${SAFEHOUSE_APPEND_PROFILES_EFFECTIVE:-}" ]]; then
      profile_list="$SAFEHOUSE_APPEND_PROFILES_EFFECTIVE"
    elif [[ -n "${SAFEHOUSE_APPEND_PROFILES:-}" ]]; then
      profile_list="$SAFEHOUSE_APPEND_PROFILES"
    else
      profile_list="$(safe_join_profile_lists \
        "$SAFEHOUSE_APPEND_PROFILES_DEFAULT" \
        "$SAFEHOUSE_APPEND_PROFILES_EXTRA")"
    fi

    [[ -z "$profile_list" ]] && return

    old_ifs=$IFS
    IFS=':'
    for profile in $profile_list; do
      printf '%s\n' "$profile"
    done
    IFS=$old_ifs
}

safe_auth_provider_env() {
    if ! command -v "$SAFE_GITHUB_AUTH_PROVIDER" >/dev/null 2>&1; then
      return 0
    fi

    "$SAFE_GITHUB_AUTH_PROVIDER" env --format=inline
}

safe_refresh_cargo_profile() {
    local cargo_profile_path cargo_profile_dir
    local xdg_lib_home xdg_data_home xdg_config_home
    local cargo_home rustup_home

    cargo_profile_path="${SAFEHOUSE_APPEND_PROFILES_CARGO:-${XDG_CACHE_HOME:-$HOME/.cache}/agent-safehouse/cargo.sb}"
    cargo_profile_dir="$(dirname "$cargo_profile_path")"

    xdg_lib_home="${XDG_LIB_HOME:-$HOME/.local/lib}"
    xdg_data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    xdg_config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

    cargo_home="${CARGO_HOME:-$xdg_lib_home/cargo}"
    rustup_home="${RUSTUP_HOME:-$xdg_data_home/rustup}"

    mkdir -p "$cargo_profile_dir"

    cat > "$cargo_profile_path" <<EOF
;; CARGO
(allow file-read* file-write*
    (subpath "$cargo_home")
    (subpath "$rustup_home")
    (subpath "$xdg_config_home/cargo")
)
EOF
}

safe_refresh_profiles() {
    safe_refresh_cargo_profile
}

safe_profile_path_for_name() {
    case "$1" in
      cargo) printf '%s\n' "$SAFEHOUSE_PROFILE_CARGO" ;;
      claude) printf '%s\n' "$SAFEHOUSE_PROFILE_CLAUDE" ;;
      codex) printf '%s\n' "$SAFEHOUSE_PROFILE_CODEX" ;;
      cursor) printf '%s\n' "$SAFEHOUSE_PROFILE_CURSOR" ;;
      gemini) printf '%s\n' "$SAFEHOUSE_PROFILE_GEMINI" ;;
      local|local-overrides) printf '%s\n' "$SAFEHOUSE_PROFILE_LOCAL_OVERRIDES" ;;
      nix) printf '%s\n' "$SAFEHOUSE_PROFILE_NIX" ;;
      dotnet) printf '%s\n' "$SAFEHOUSE_PROFILE_DOTNET" ;;
      docker) printf '%s\n' "$SAFEHOUSE_PROFILE_DOCKER" ;;
      *)
        echo "safe: unknown profile name '$1'" >&2
        return 1
        ;;
    esac
}

safe_profile_extra_for_name() {
    case "$1" in
      claude) printf '%s\n' "$SAFEHOUSE_APPEND_PROFILES_CLAUDE_EXTRA" ;;
      codex) printf '%s\n' "$SAFEHOUSE_APPEND_PROFILES_CODEX_EXTRA" ;;
      cursor) printf '%s\n' "$SAFEHOUSE_APPEND_PROFILES_CURSOR_EXTRA" ;;
      gemini) printf '%s\n' "$SAFEHOUSE_APPEND_PROFILES_GEMINI_EXTRA" ;;
      nix) printf '%s\n' "$SAFEHOUSE_APPEND_PROFILES_NIX_EXTRA" ;;
      dotnet) printf '%s\n' "$SAFEHOUSE_APPEND_PROFILES_DOTNET_EXTRA" ;;
      docker) printf '%s\n' "$SAFEHOUSE_APPEND_PROFILES_DOCKER_EXTRA" ;;
      *)
        printf '%s\n' ""
        ;;
    esac
}

safe_parse_args() {
    local -a remaining_args safehouse_args
    local parsed_profiles=""
    local parsed_profile_extras=""
    local profile_path=""
    local profile_name=""

    while [ "$#" -gt 0 ]; do
      case "$1" in
        --with-cargo|--with-claude|--with-codex|--with-cursor|--with-gemini|--with-local|--with-local-overrides|--with-nix|--with-dotnet|--with-docker)
          profile_name="${1#--with-}"
          profile_path="$(safe_profile_path_for_name "$profile_name")" || return 1
          parsed_profiles="$(safe_join_profile_lists "$parsed_profiles" "$profile_path")"
          parsed_profile_extras="$(safe_join_profile_lists "$parsed_profile_extras" "$(safe_profile_extra_for_name "$profile_name")")"
          shift
          ;;
        --with-profile)
          if [ "$#" -lt 2 ]; then
            echo "safe: missing value for --with-profile" >&2
            return 1
          fi
          parsed_profiles="$(safe_join_profile_lists "$parsed_profiles" "$2")"
          shift 2
          ;;
        --with-profile=*)
          parsed_profiles="$(safe_join_profile_lists "$parsed_profiles" "${1#--with-profile=}")"
          shift
          ;;
        --enable|--env-pass|--add-dirs-ro|--add-dirs|--workdir|--append-profile|--output)
          if [ "$#" -lt 2 ]; then
            echo "safe: missing value for $1" >&2
            return 1
          fi
          safehouse_args+=("$1" "$2")
          shift 2
          ;;
        --enable=*|--env=*|--env-pass=*|--add-dirs-ro=*|--add-dirs=*|--workdir=*|--trust-workdir-config=*|--append-profile=*|--output=*)
          safehouse_args+=("$1")
          shift
          ;;
        --env|--stdout|--explain|--version|-h|--help|--trust-workdir-config)
          safehouse_args+=("$1")
          shift
          ;;
        --)
          shift
          while [ "$#" -gt 0 ]; do
            remaining_args+=("$1")
            shift
          done
          break
          ;;
        *)
          while [ "$#" -gt 0 ]; do
            remaining_args+=("$1")
            shift
          done
          break
          ;;
      esac
    done

    SAFEHOUSE_PARSED_EXTRA_PROFILES="$parsed_profiles"
    SAFEHOUSE_PARSED_PROFILE_EXTRAS="$parsed_profile_extras"
    SAFEHOUSE_PARSED_SAFEHOUSE_ARGS=("${safehouse_args[@]}")
    SAFEHOUSE_PARSED_ARGS=("${remaining_args[@]}")
}

safe_print_help() {
    cat <<'EOF'
Usage:
  safe [profile options] [--] <command> [args...]

Profile options:
  --with-cargo
  --with-claude
  --with-codex
  --with-cursor
  --with-gemini
  --with-docker
  --with-local
  --with-local-overrides
  --with-nix
  --with-profile PATH
  --with-profile=PATH
  --help

Safehouse passthrough options:
  --enable FEATURES
  --enable=FEATURES
  --env
  --env=FILE
  --env-pass NAMES
  --env-pass=NAMES
  --add-dirs-ro PATHS
  --add-dirs-ro=PATHS
  --add-dirs PATHS
  --add-dirs=PATHS
  --workdir DIR
  --workdir=DIR
  --trust-workdir-config
  --trust-workdir-config=BOOL
  --append-profile PATH
  --append-profile=PATH
  --output PATH
  --output=PATH
  --stdout
  --explain
  --version
  -h, --help

Environment:
  SAFEHOUSE_APPEND_PROFILES
  SAFEHOUSE_APPEND_PROFILES_EXTRA
  SAFEHOUSE_APPEND_PROFILES_CLAUDE_EXTRA
  SAFEHOUSE_APPEND_PROFILES_CODEX_EXTRA
  SAFEHOUSE_APPEND_PROFILES_CURSOR_EXTRA
  SAFEHOUSE_APPEND_PROFILES_GEMINI_EXTRA
  SAFEHOUSE_APPEND_PROFILES_NIX_EXTRA
  SAFEHOUSE_APPEND_PROFILES_DOCKER_EXTRA

Exported profile paths:
  SAFEHOUSE_PROFILE_LOCAL_OVERRIDES
  SAFEHOUSE_PROFILE_CARGO
  SAFEHOUSE_PROFILE_CLAUDE
  SAFEHOUSE_PROFILE_CODEX
  SAFEHOUSE_PROFILE_CURSOR
  SAFEHOUSE_PROFILE_GEMINI
  SAFEHOUSE_PROFILE_NIX
  SAFEHOUSE_PROFILE_DOCKER
EOF
}

safe_args_include_help() {
    local arg
    for arg in "$@"; do
      if [ "$arg" = "--help" ]; then
        return 0
      fi
    done
    return 1
}

safe() {
    local -a append_profile_args auth_provider_env
    local auth_provider_env_inline
    local profile append_profiles inherited_profiles

    if safe_args_include_help "$@"; then
      safe_print_help
      return 0
    fi

    safe_refresh_profiles
    safe_parse_args "$@" || return 1
    set -- "${SAFEHOUSE_PARSED_ARGS[@]}"

    inherited_profiles="${SAFEHOUSE_APPEND_PROFILES_EFFECTIVE:-${SAFEHOUSE_APPEND_PROFILES:-}}"
    append_profiles="$(safe_join_profile_lists \
      "$SAFEHOUSE_APPEND_PROFILES_DEFAULT" \
      "$inherited_profiles" \
      "$SAFEHOUSE_APPEND_PROFILES_EXTRA" \
      "$SAFEHOUSE_PARSED_PROFILE_EXTRAS" \
      "$SAFEHOUSE_PARSED_EXTRA_PROFILES")"
    local SAFEHOUSE_APPEND_PROFILES_EFFECTIVE="$append_profiles"

    while IFS= read -r profile; do
      [[ -z "$profile" ]] && continue
      append_profile_args+=(--append-profile="$profile")
    done < <(safe_append_profiles)

    auth_provider_env_inline="$(safe_auth_provider_env)"
    if [[ -n "$auth_provider_env_inline" ]]; then
      # github-auth-provider emits trusted shell words like KEY=value.
      eval "auth_provider_env=($auth_provider_env_inline)"
    else
      auth_provider_env=()
    fi

    echo "start sandbox ${append_profile_args[*]}" && \
    safehouse --add-dirs-ro="$WORK_BASE" \
      "${append_profile_args[@]}" \
      "${SAFEHOUSE_PARSED_SAFEHOUSE_ARGS[@]}" \
      --env-pass="GITHUB_AUTH_PROVIDER_PROJECT,GIT_TRACE,CLAUDE_CONFIG_DIR" -- "${auth_provider_env[@]}" "$@";
}

is_nix_shell() {
  [[ -n "$IN_NIX_SHELL" ]]
}

safe_nix_shell_aware() {
  local extra_profiles

  if safe_args_include_help "$@"; then
    safe_print_help
    printf '\nWrapper:\n  safe_nix_shell_aware [profile options] [--] <command> [args...]\n'
    return 0
  fi

  safe_parse_args "$@" || return 1
  extra_profiles="$(safe_join_profile_lists \
    "$SAFEHOUSE_APPEND_PROFILES_EXTRA" \
    "$SAFEHOUSE_PARSED_PROFILE_EXTRAS" \
    "$SAFEHOUSE_PARSED_EXTRA_PROFILES")"
  local SAFEHOUSE_APPEND_PROFILES_EXTRA="$extra_profiles"

  if is_nix_shell; then
    safe --with-nix "${SAFEHOUSE_PARSED_SAFEHOUSE_ARGS[@]}" -- \
      env QUIET_NIX_SHELL=1 nix develop --command "${SAFEHOUSE_PARSED_ARGS[@]}"
  else
    safe "${SAFEHOUSE_PARSED_SAFEHOUSE_ARGS[@]}" "${SAFEHOUSE_PARSED_ARGS[@]}"
  fi
}

if command -v claude >/dev/null 2>&1; then
  claude_path="$(command -v claude)"
  claude() {
    local extra_profiles

    if safe_args_include_help "$@"; then
      safe_print_help
      printf '\nWrapper:\n  claude [profile options] [--] [claude args...]\n'
      return 0
    fi
    safe_parse_args "$@" || return 1
    extra_profiles="$(safe_join_profile_lists \
      "$SAFEHOUSE_APPEND_PROFILES_EXTRA" \
      "$SAFEHOUSE_PARSED_PROFILE_EXTRAS" \
      "$SAFEHOUSE_PARSED_EXTRA_PROFILES")"
    local SAFEHOUSE_APPEND_PROFILES_EXTRA="$extra_profiles"

    if is_nix_shell; then
      safe --with-nix --with-claude "${SAFEHOUSE_PARSED_SAFEHOUSE_ARGS[@]}" env QUIET_NIX_SHELL=1 nix develop --command \
        "$claude_path" --dangerously-skip-permissions "${SAFEHOUSE_PARSED_ARGS[@]}"
    else
      safe --with-claude "${SAFEHOUSE_PARSED_SAFEHOUSE_ARGS[@]}" "$claude_path" --dangerously-skip-permissions "${SAFEHOUSE_PARSED_ARGS[@]}"
    fi
  }
fi

if command -v codex >/dev/null 2>&1; then
  codex_path="$(command -v codex)"
  codex() {
      local extra_profiles

      if safe_args_include_help "$@"; then
        safe_print_help
        printf '\nWrapper:\n  codex [profile options] [--] [codex args...]\n'
        return 0
      fi
      safe_parse_args "$@" || return 1
      extra_profiles="$(safe_join_profile_lists \
        "$SAFEHOUSE_APPEND_PROFILES_EXTRA" \
        "$SAFEHOUSE_PARSED_PROFILE_EXTRAS" \
        "$SAFEHOUSE_PARSED_EXTRA_PROFILES")"
      local SAFEHOUSE_APPEND_PROFILES_EXTRA="$extra_profiles"

      if is_nix_shell; then
        safe --with-nix --with-codex "${SAFEHOUSE_PARSED_SAFEHOUSE_ARGS[@]}" env QUIET_NIX_SHELL=1 nix develop --command \
          "$codex_path" --dangerously-bypass-approvals-and-sandbox "${SAFEHOUSE_PARSED_ARGS[@]}"
      else
        safe --with-codex "${SAFEHOUSE_PARSED_SAFEHOUSE_ARGS[@]}" "$codex_path" --dangerously-bypass-approvals-and-sandbox "${SAFEHOUSE_PARSED_ARGS[@]}"
      fi
  }
fi

if command -v cursor-agent >/dev/null 2>&1; then
  cursor_agent_path="$(command -v cursor-agent)"
  cursor-agent() {
      local extra_profiles

      if safe_args_include_help "$@"; then
        safe_print_help
        printf '\nWrapper:\n  cursor-agent [profile options] [--] [cursor-agent args...]\n'
        return 0
      fi
      safe_parse_args "$@" || return 1
      extra_profiles="$(safe_join_profile_lists \
        "$SAFEHOUSE_APPEND_PROFILES_EXTRA" \
        "$SAFEHOUSE_PARSED_PROFILE_EXTRAS" \
        "$SAFEHOUSE_PARSED_EXTRA_PROFILES")"
      local SAFEHOUSE_APPEND_PROFILES_EXTRA="$extra_profiles"

      if is_nix_shell; then
        safe --with-nix --with-cursor "${SAFEHOUSE_PARSED_SAFEHOUSE_ARGS[@]}" env QUIET_NIX_SHELL=1 nix develop --command \
          "$cursor_agent_path" "${SAFEHOUSE_PARSED_ARGS[@]}"
      else
        safe --with-cursor "${SAFEHOUSE_PARSED_SAFEHOUSE_ARGS[@]}" "$cursor_agent_path" --force "${SAFEHOUSE_PARSED_ARGS[@]}"
      fi
  }
fi

gemini() {
  local extra_profiles

  if safe_args_include_help "$@"; then
    safe_print_help
    printf '\nWrapper:\n  gemini [profile options] [--] [gemini args...]\n'
    return 0
  fi
  safe_parse_args "$@" || return 1
  extra_profiles="$(safe_join_profile_lists \
    "$SAFEHOUSE_APPEND_PROFILES_EXTRA" \
    "$SAFEHOUSE_PARSED_PROFILE_EXTRAS" \
    "$SAFEHOUSE_PARSED_EXTRA_PROFILES")"
  local SAFEHOUSE_APPEND_PROFILES_EXTRA="$extra_profiles"

  if is_nix_shell; then
    NO_BROWSER=true safe --with-nix --with-gemini "${SAFEHOUSE_PARSED_SAFEHOUSE_ARGS[@]}" env QUIET_NIX_SHELL=1 nix develop --command \
      gemini --yolo "${SAFEHOUSE_PARSED_ARGS[@]}"
  else
    NO_BROWSER=true safe --with-gemini "${SAFEHOUSE_PARSED_SAFEHOUSE_ARGS[@]}" gemini --yolo "${SAFEHOUSE_PARSED_ARGS[@]}"
  fi
}

if command -v agent-skill-sync >/dev/null 2>&1; then
  agent-skill-sync
fi
