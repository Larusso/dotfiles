#
# Fzf configuration module for zsh.
#

case $(uname) in
  'Linux')
    fzf_path="/usr/share/fzf"
    ;;
  'Darwin') 
    fzf_path="/usr/local/opt/fzf/shell"
    ;;
  *) ;;
esac

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$fzf_path/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$fzf_path/key-bindings.zsh"

