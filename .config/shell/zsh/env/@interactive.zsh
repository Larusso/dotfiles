#
# Env configuration module for zsh.
#

xsh load env -s posix

# Init direnv
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi
