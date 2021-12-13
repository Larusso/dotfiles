#
# Powerlevel10k configuration module for zsh.
#
# Enable Powerlevel9k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p9k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p9k-instant-prompt-${(%):-%n}.zsh"
fi

function p10k_theme_install_path {
  p10k_install_paths=( 
    "${XDG_DATA_HOME:-$HOME/.local/share}/powerlevel10k"
    "/usr/share/zsh-theme-powerlevel10k/"
    "/usr/local/opt/powerlevel10k/"  
  )

  for path in "${p10k_install_paths[@]}"
  do
    theme_file="$path/powerlevel10k.zsh-theme"
    if [ -f "$theme_file" ]; then
      echo "$theme_file"
      return 0
    fi
  done
  return 1
}

#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=("os_icon" "dir" "vcs" "newline" "status" "vim_shell")
#POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=("direnv" "asdf" "pyenv" "rbenv" "nodenv" "nix_shell")
#POWERLEVEL9K_SHOW_CHANGESET=false;
#POWERLEVEL9K_VCS_HIDE_TAGS=true;
#POWERLEVEL9K_MODE="nerdfont-complete";
#POWERLEVEL9K_PROMPT_ON_NEWLINE=true;
#POWERLEVEL9K_RPROMPT_ON_NEWLINE=false;
#POWERLEVEL9K_STATUS_VERBOSE=true;
#POWERLEVEL9K_STATUS_CROSS=true;
#POWERLEVEL9K_PROMPT_ADD_NEWLINE=true;

if [ "$TERM" = "linux"]; then
  p10k_theme_config="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.p10k-term-linux.zsh"
else
  p10k_theme_config="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.p10k.zsh"
fi

p10k_theme="$(p10k_theme_install_path)"

if [ $? ]; then
  source "$p10k_theme"
  [[ ! -f $p10k_theme_config ]] || source "$p10k_theme_config"
fi
