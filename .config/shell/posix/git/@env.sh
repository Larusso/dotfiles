#
# Git configuration module.
#

SSH_LOGGER_PATH="${XDG_BIN_HOME:-$HOME/.local/bin}/ssh_logger"

if [ -f "$SSH_LOGGER_PATH" ]; then
  export GIT_SSH_COMMAND="$SSH_LOGGER_PATH"
else
  echo "Warning: $SSH_LOGGER_PATH does not exist. GIT_SSH_COMMAND not set."
fi
