command -v nix >/dev/null 2>&1 || return 1

# Update flake.lock to latest nixpkgs and upgrade the installed profile
nix-sync() {
  local flake="${XDG_CONFIG_HOME:-$HOME/.config}/yadm"
  (cd "$flake" && nix flake update) && nix profile upgrade '.*'
}

# Wrapper for home-manager switch/build pointing to the yadm flake
home-manager() {
  local flake="${XDG_CONFIG_HOME:-$HOME/.config}/yadm"
  local real_hm="$HOME/.nix-profile/bin/home-manager"
  if [ ! -x "$real_hm" ]; then
    echo "home-manager is not installed yet. Run: ~/.config/yadm/bootstrap.d/037-switch-home-manager" >&2
    return 1
  fi

  local needs_flake=0 has_flake=0 arg
  for arg in "$@"; do
    case "$arg" in
      switch|build) needs_flake=1 ;;
      --flake|--flake=*) has_flake=1 ;;
    esac
  done

  if [[ "$needs_flake" -eq 1 && "$has_flake" -eq 0 ]]; then
    if [[ ! -f "$flake/home/machine.nix" ]]; then
      echo "Missing $flake/home/machine.nix. Run: yadm alt" >&2
      return 1
    fi
    local system
    system="$(nix eval --impure --raw --expr builtins.currentSystem)"
    local -a args=()
    for arg in "$@"; do
      args+=("$arg")
      if [[ "$arg" == switch || "$arg" == build ]]; then
        args+=(--flake "${flake}#${system}")
      fi
    done
    "$real_hm" "${args[@]}"
  else
    "$real_hm" "$@"
  fi
}

# Upgrade the Nix package manager itself and restart the daemon
nix-upgrade() {
  sudo nix upgrade-nix
  if [[ "$(uname)" == "Darwin" ]]; then
    sudo launchctl kickstart -k system/org.nixos.nix-daemon
  fi
}
