#
# Core configuration module for zsh.
#
xsh load core -s posix

HISTSIZE="10000"
SAVEHIST="10000"
HISTFILE="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY

#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=("os_icon" "dir" "vcs" "newline" "status")
#POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=("direnv" "asdf" "pyenv" "rbenv" "nodenv" "nix_shell")
#POWERLEVEL9K_SHOW_CHANGESET=false;
#POWERLEVEL9K_VCS_HIDE_TAGS=true;
#POWERLEVEL9K_MODE="nerdfont-complete";
#POWERLEVEL9K_PROMPT_ON_NEWLINE=true;
#POWERLEVEL9K_RPROMPT_ON_NEWLINE=false;
#POWERLEVEL9K_STATUS_VERBOSE=true;
#POWERLEVEL9K_STATUS_CROSS=true;
#POWERLEVEL9K_PROMPT_ADD_NEWLINE=true;

#. /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
. /usr/share/fzf/key-bindings.zsh
. /usr/share/fzf/completion.zsh