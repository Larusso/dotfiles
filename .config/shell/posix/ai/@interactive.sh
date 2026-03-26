
_SAFEHOUSE_APPEND_PROFILE="$HOME/.config/agent-safehouse/local-overrides.sb"
WORK_BASE="$HOME/work"

safe() { echo "start sandbox ${SAFEHOUSE_APPEND_PROFILE:-$_SAFEHOUSE_APPEND_PROFILE}" && safehouse --add-dirs-ro="$WORK_BASE" --append-profile="${SAFEHOUSE_APPEND_PROFILE:-$_SAFEHOUSE_APPEND_PROFILE}" "$@"; }
safeenv() { safe --env "$@"; }
safekeys() { safe --env-pass=OPENAI_API_KEY,ANTHROPIC_API_KEY,GEMINI_API_KEY "$@"; }
claude()   { SAFEHOUSE_APPEND_PROFILE="${SAFEHOUSE_APPEND_PROFILE_CLAUDE:-$_SAFEHOUSE_APPEND_PROFILE}" safe claude --dangerously-skip-permissions "$@"; }
codex()    { safe codex --dangerously-bypass-approvals-and-sandbox "$@"; }
opencode() { OPENCODE_PERMISSION='{"*":"allow"}' safekeys opencode "$@"; }
gemini()   { NO_BROWSER=true safekeys gemini --yolo "$@"; }
