
_SAFEHOUSE_APPEND_PROFILE="$HOME/.config/agent-safehouse/local-overrides.sb"
WORK_BASE="$HOME/work"

is_nix_shell() {
  [[ -n "$IN_NIX_SHELL" ]]
}

safe() { echo "start sandbox ${SAFEHOUSE_APPEND_PROFILE:-$_SAFEHOUSE_APPEND_PROFILE}" && safehouse --add-dirs-ro="$WORK_BASE" --append-profile="${SAFEHOUSE_APPEND_PROFILE:-$_SAFEHOUSE_APPEND_PROFILE}" "$@"; }
safeenv() { safe --env "$@"; }
safekeys() { safe --env-pass=OPENAI_API_KEY,ANTHROPIC_API_KEY,GEMINI_API_KEY "$@"; }

safe_nix_shell_aware() {
  local -a cmd
  if is_nix_shell; then
    cmd=(env QUIET_NIX_SHELL=1 nix develop --command "$@")
  else
    cmd=("$@")
  fi

  safe "${cmd[@]}"
}

claude() {
  SAFEHOUSE_APPEND_PROFILE="${SAFEHOUSE_APPEND_PROFILE_CLAUDE:-$_SAFEHOUSE_APPEND_PROFILE}" \
    safe_nix_shell_aware claude --dangerously-skip-permissions "$@"
}

codex() {
  safe_nix_shell_aware codex --dangerously-bypass-approvals-and-sandbox "$@"
}

opencode() {
  OPENCODE_PERMISSION='{"*":"allow"}' \
    safe_nix_shell_aware opencode "$@"
}

gemini() {
  NO_BROWSER=true \
    safe_nix_shell_aware gemini --yolo "$@"
}
