use_tmux() {
    # Eval the helper script which creates the session and outputs commands to eval
    eval "$("${XDG_CONFIG_HOME:-$HOME/.config}/direnv/lib/use_tmux.sh" "$@")"
}
