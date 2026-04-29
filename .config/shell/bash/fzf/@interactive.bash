#
# Fzf configuration module for bash.
#

fzf_shell_path() {
  local candidates=(
    "${HOME}/.nix-profile/share/fzf"
    "/usr/share/fzf"
    "/opt/homebrew/opt/fzf/shell"
    "/usr/local/opt/fzf/shell"
  )
  for dir in "${candidates[@]}"; do
    [[ -f "${dir}/key-bindings.bash" ]] && echo "$dir" && return 0
  done
  return 1
}

fzf_path="$(fzf_shell_path)" || return 1

# Auto-completion
[[ $- == *i* ]] && source "${fzf_path}/completion.bash" 2>/dev/null

# Key bindings
source "${fzf_path}/key-bindings.bash"
