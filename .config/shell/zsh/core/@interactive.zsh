#
# Core configuration module for zsh.
#
xsh load core -s posix

alias reload='exec "$XSHELL"' # reload the current shell configuration

eval "$(starship init zsh)"

