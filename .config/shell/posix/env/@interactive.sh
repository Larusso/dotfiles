#
# Env configuration module.
#

# Init rbenv
if command -v rbenv &> /dev/null; then
    eval "$(rbenv init -)"
fi

# Init nodenv
if command -v nodenv &> /dev/null; then
    eval "$(nodenv init -)"
fi
