
_SAFEHOUSE_APPEND_PROFILE="$HOME/.config/agent-safehouse/local-overrides.sb"
WORK_BASE="$HOME/work"

safe_debug() {
    /usr/bin/log stream \
      --style compact \
      --predicate 'eventMessage CONTAINS "Sandbox:" AND eventMessage CONTAINS "deny("'
}

safe() {
    echo "start sandbox ${SAFEHOUSE_APPEND_PROFILE:-$_SAFEHOUSE_APPEND_PROFILE}" && \
    safehouse --add-dirs-ro="$WORK_BASE" \
      --append-profile="${SAFEHOUSE_APPEND_PROFILE:-$_SAFEHOUSE_APPEND_PROFILE}" "$@";
}

is_nix_shell() {
  [[ -n "$IN_NIX_SHELL" ]]
}

safe_nix_shell_aware() {
  local -a cmd
  if is_nix_shell; then
    cmd=(env QUIET_NIX_SHELL=1 nix develop --command "$@")
  else
    cmd=("$@")
  fi

  safe "${cmd[@]}"
}

if command -v codex >/dev/null 2>&1; then
  claude_path="$(command -v claude)"
  claude() {
    SAFEHOUSE_APPEND_PROFILE="${SAFEHOUSE_APPEND_PROFILE_CLAUDE:-$_SAFEHOUSE_APPEND_PROFILE}" \
    safe_nix_shell_aware "$claude_path" --dangerously-skip-permissions "$@"
  }
fi

if command -v codex >/dev/null 2>&1; then
  codex_path="$(command -v codex)"
  codex() {
      safe_nix_shell_aware "$codex_path" --dangerously-bypass-approvals-and-sandbox "$@"
  }
fi

gemini() {
  NO_BROWSER=true \
    safe_nix_shell_aware gemini --yolo "$@"
}
