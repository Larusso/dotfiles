command -v nix >/dev/null 2>&1 || return 1

# Update flake.lock to latest nixpkgs and upgrade the installed profile
nix-sync() {
  local flake="${XDG_CONFIG_HOME:-$HOME/.config}/yadm"
  (cd "$flake" && nix flake update) && nix profile upgrade '.*'
}
