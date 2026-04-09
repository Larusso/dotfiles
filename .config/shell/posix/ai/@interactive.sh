#!/usr/bin/env bash

export SAFEHOUSE_PROFILE_LOCAL_OVERRIDES="${SAFEHOUSE_PROFILE_LOCAL_OVERRIDES:-$HOME/.config/agent-safehouse/local-overrides.sb}"
export SAFEHOUSE_PROFILE_CARGO="${SAFEHOUSE_PROFILE_CARGO:-${XDG_CACHE_HOME:-$HOME/.cache}/agent-safehouse/cargo.sb}"
export SAFEHOUSE_PROFILE_CLAUDE="${SAFEHOUSE_PROFILE_CLAUDE:-$HOME/.config/agent-safehouse/claude.sb}"
export SAFEHOUSE_PROFILE_CODEX="${SAFEHOUSE_PROFILE_CODEX:-$HOME/.config/agent-safehouse/codex.sb}"
export SAFEHOUSE_PROFILE_GEMINI="${SAFEHOUSE_PROFILE_GEMINI:-$HOME/.config/agent-safehouse/gemini.sb}"
export SAFEHOUSE_PROFILE_NIX="${SAFEHOUSE_PROFILE_NIX:-$HOME/.config/agent-safehouse/nix.sb}"
SAFEHOUSE_APPEND_PROFILES_CARGO="${SAFEHOUSE_APPEND_PROFILES_CARGO:-$SAFEHOUSE_PROFILE_CARGO}"
SAFEHOUSE_APPEND_PROFILES_DEFAULT="${SAFEHOUSE_APPEND_PROFILES_DEFAULT:-$SAFEHOUSE_PROFILE_LOCAL_OVERRIDES}"
SAFEHOUSE_APPEND_PROFILES_CLAUDE="${SAFEHOUSE_APPEND_PROFILES_CLAUDE:-$SAFEHOUSE_PROFILE_CLAUDE}"
SAFEHOUSE_APPEND_PROFILES_CODEX="${SAFEHOUSE_APPEND_PROFILES_CODEX:-$SAFEHOUSE_PROFILE_CODEX}"
SAFEHOUSE_APPEND_PROFILES_GEMINI="${SAFEHOUSE_APPEND_PROFILES_GEMINI:-$SAFEHOUSE_PROFILE_GEMINI}"
SAFEHOUSE_APPEND_PROFILES_NIX="${SAFEHOUSE_APPEND_PROFILES_NIX:-$SAFEHOUSE_PROFILE_NIX}"
SAFEHOUSE_APPEND_PROFILES_EXTRA="${SAFEHOUSE_APPEND_PROFILES_EXTRA:-}"
SAFEHOUSE_APPEND_PROFILES_CLAUDE_EXTRA="${SAFEHOUSE_APPEND_PROFILES_CLAUDE_EXTRA:-}"
SAFEHOUSE_APPEND_PROFILES_CODEX_EXTRA="${SAFEHOUSE_APPEND_PROFILES_CODEX_EXTRA:-}"
SAFEHOUSE_APPEND_PROFILES_GEMINI_EXTRA="${SAFEHOUSE_APPEND_PROFILES_GEMINI_EXTRA:-}"
SAFEHOUSE_APPEND_PROFILES_NIX_EXTRA="${SAFEHOUSE_APPEND_PROFILES_NIX_EXTRA:-}"
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
    /Users/larusso/work/wooga/ai_tools/github-auth-provider/target/release/github-auth-provider env --format=inline
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

safe() {
    local -a append_profile_args auth_provider_env
    local auth_provider_env_inline
    local profile

    safe_refresh_profiles

    while IFS= read -r profile; do
      [[ -z "$profile" ]] && continue
      append_profile_args+=(--append-profile="$profile")
    done < <(safe_append_profiles)

    auth_provider_env_inline="$(safe_auth_provider_env)"
    # github-auth-provider emits trusted shell words like KEY=value.
    eval "auth_provider_env=($auth_provider_env_inline)"

    echo "start sandbox ${append_profile_args[*]}" && \
    safehouse --add-dirs-ro="$WORK_BASE" \
      "${append_profile_args[@]}" \
      --env-pass="GITHUB_AUTH_PROVIDER_PROJECT,GIT_TRACE" -- "${auth_provider_env[@]}" "$@";
}

is_nix_shell() {
  [[ -n "$IN_NIX_SHELL" ]]
}

safe_nix_shell_aware() {
  local -a cmd
  local append_profiles
  local inherited_profiles

  inherited_profiles="${SAFEHOUSE_APPEND_PROFILES_EFFECTIVE:-${SAFEHOUSE_APPEND_PROFILES:-}}"

  if is_nix_shell; then
    append_profiles="$(safe_join_profile_lists \
      "$inherited_profiles" \
      "$SAFEHOUSE_APPEND_PROFILES_NIX" \
      "$SAFEHOUSE_APPEND_PROFILES_NIX_EXTRA" \
      "$SAFEHOUSE_APPEND_PROFILES_EXTRA")"
    cmd=(env QUIET_NIX_SHELL=1 nix develop --command "$@")
  else
    append_profiles="$(safe_join_profile_lists \
      "$inherited_profiles" \
      "$SAFEHOUSE_APPEND_PROFILES_EXTRA")"
    cmd=("$@")
  fi

  local SAFEHOUSE_APPEND_PROFILES_EFFECTIVE="$append_profiles"
  safe "${cmd[@]}"
}

if command -v claude >/dev/null 2>&1; then
  claude_path="$(command -v claude)"
  claude() {
    local append_profiles
    append_profiles="$(safe_join_profile_lists \
      "$SAFEHOUSE_APPEND_PROFILES_CLAUDE" \
      "$SAFEHOUSE_APPEND_PROFILES_CLAUDE_EXTRA" \
      "${SAFEHOUSE_APPEND_PROFILES:-}")"
    local SAFEHOUSE_APPEND_PROFILES_EFFECTIVE="$append_profiles"
    safe_nix_shell_aware "$claude_path" --dangerously-skip-permissions "$@"
  }
fi

if command -v codex >/dev/null 2>&1; then
  codex_path="$(command -v codex)"
  codex() {
      local append_profiles
      append_profiles="$(safe_join_profile_lists \
        "$SAFEHOUSE_APPEND_PROFILES_CODEX" \
        "$SAFEHOUSE_APPEND_PROFILES_CODEX_EXTRA" \
        "${SAFEHOUSE_APPEND_PROFILES:-}")"
      local SAFEHOUSE_APPEND_PROFILES_EFFECTIVE="$append_profiles"
      safe_nix_shell_aware "$codex_path" --dangerously-bypass-approvals-and-sandbox "$@"
  }
fi

gemini() {
  local append_profiles
  append_profiles="$(safe_join_profile_lists \
    "$SAFEHOUSE_APPEND_PROFILES_GEMINI" \
    "$SAFEHOUSE_APPEND_PROFILES_GEMINI_EXTRA" \
    "${SAFEHOUSE_APPEND_PROFILES:-}")"
  local SAFEHOUSE_APPEND_PROFILES_EFFECTIVE="$append_profiles"
  NO_BROWSER=true safe_nix_shell_aware gemini --yolo "$@"
}
