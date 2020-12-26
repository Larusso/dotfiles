#
# Core configuration module for bash.
#
xsh load core -s posix
alias reload='exec "$XSHELL"' # reload the current shell configuration

eval "$(starship init bash)"

. /usr/share/fzf/key-bindings.bash
. /usr/share/fzf/completion.bash