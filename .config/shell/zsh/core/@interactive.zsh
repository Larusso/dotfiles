#
# Core configuration module for zsh.
#

xsh load core -s posix
autoload -Uz compinit && compinit

HISTSIZE="10000"
SAVEHIST="10000"

history_file="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.zsh_history"
HISTFILE=$history_file
mkdir -p "$(dirname "$history_file")"

setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY

colors() {
  for i in {0..255}; do let "c=255"; print -Pn "%K{$i} %F{$c}${(l:3::0:)i}%f %k " ${${(M)$((i%6)):#3}:+$'\n'}; done
}

xsh_debug() {
    XSH_VERBOSE=1 XSH_BENCHMARK=1 zsh
}
