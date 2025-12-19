# Shared logging functions for yadm bootstrap scripts
# Source with: source "${XDG_CONFIG_HOME:-$HOME/.config}/yadm/lib.zsh"

function log_header() {
  print -P "\n%F{cyan}━━━ %F{white}%B$1%b %F{cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%f"
}

function log_step() {
  print -P "  %F{blue}→%f $1"
}

function log_done() {
  print -P "  %F{green}✓%f ${1:-Done}"
}

function log_warn() {
  print -P "  %F{yellow}⚠%f $1"
}

function log_skip() {
  print -P "  %F{yellow}⚠%f $1, skipping"
}

function log_prompt() {
  print -Pn "  %F{yellow}?%f $1 "
}

