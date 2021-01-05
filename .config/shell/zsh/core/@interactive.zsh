#
# Core configuration module for zsh.
#

xsh load core -s posix

HISTSIZE="10000"
SAVEHIST="10000"

history_file="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.zsh_history"

mkdir -p "$(dirname "$history_file")"

setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY

