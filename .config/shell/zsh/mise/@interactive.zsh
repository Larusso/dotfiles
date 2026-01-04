if ! command -v mise &> /dev/null
then
  return 1
fi

eval "$(mise activate zsh)"