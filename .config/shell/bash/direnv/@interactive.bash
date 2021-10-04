#
# Direnv configuration module for bash.
#

# Abort if requirements are not met.
if ! command -v direnv &> /dev/null
then
  return 1
fi

# Setup and cache the shell hook.
direnv_cache="$XDG_CACHE_HOME/direnv/hook.bash"
if [[ ! -s "$direnv_cache" || $commands[direnv] -nt $direnv_cache ]]; then
  command mkdir -p ${direnv_cache:h} && direnv hook bash >|"$direnv_cache"
fi
source $direnv_cache

unset direnv_cache
