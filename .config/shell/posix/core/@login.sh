#
# Core configuration module.
#
# Only add directories to PATH if they exist
add_to_path_if_exists() {
  [ -d "$1" ] && PATH="$1:$PATH"
}

add_to_path_if_exists "$HOME/.dotnet"
add_to_path_if_exists "$HOME/.dotnet/tools"
add_to_path_if_exists "/usr/local/bin"
add_to_path_if_exists "/nix/var/nix/profiles/default/bin"
add_to_path_if_exists "/opt/homebrew/bin"
add_to_path_if_exists "$HOME/.local/bin"

export PATH

# Do not create group/world writable files by default.
umask a=rx,u+w
