#
# Core configuration module for zsh.
#

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

xsh load core -s posix

HISTSIZE="10000"
SAVEHIST="10000"
history_file="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.zsh_history"

p10k_theme_path="${XDG_DATA_HOME:-$HOME/.local/share}/powerlevel10k"

case $(uname) in
  'Linux')
    if [ -d "/usr/share/zsh-theme-powerlevel10k" ]; then
      p10k_theme_path="/usr/share/zsh-theme-powerlevel10k/"
    fi
    ;;
  'Darwin') 
    if [ -d "/usr/local/opt/powerlevel10k/" ]; then
      p10k_theme_path="/usr/local/opt/powerlevel10k/"
    fi
    ;;
  *) ;;
esac

p10k_theme_config="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.p10k.zsh"
p10k_theme="${p10k_theme_path}/powerlevel10k.zsh-theme"

mkdir -p "$(dirname "$history_file")"

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

if [ -f $p10k_theme ]; then
  source "$p10k_theme"
  [[ ! -f $p10k_theme_config ]] || source "$p10k_theme_config"
fi

source "/usr/share/fzf/key-bindings.zsh"
source "/usr/share/fzf/completion.zsh"
