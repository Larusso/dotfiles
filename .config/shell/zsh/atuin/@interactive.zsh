#
# Atuin configuration module for zsh.
#
export ATUIN_NOBIND="true"

_atuin_preexec() {
    local id; id=$(atuin history start -- "$1")
    export ATUIN_HISTORY_ID="${id}"
}

_atuin_precmd() {
    local EXIT="$?"

    [[ -z "${ATUIN_HISTORY_ID}" ]] && return

    (RUST_LOG=error atuin history end --exit "${EXIT}" -- "${ATUIN_HISTORY_ID}" &) > /dev/null 2>&1
}

__atuin_history ()
{
    emulate -L zsh
    ATUIN_PREFIX="atuin search --cmd-only"
    INITIAL_QUERY="${*:-}"

    echoti rmkx
    #HISTORY="$(RUST_LOG=error atuin search -i -- "${READLINE_LINE}" 3>&1 1>&2 2>&3)"
    IFS=: read -rA selected < <(
      FZF_DEFAULT_COMMAND="$ATUIN_PREFIX $(printf %q "$INITIAL_QUERY")" \
      fzf --ansi \
          --disabled --query "$INITIAL_QUERY" \
          --height=50% \
          --bind "change:reload:sleep 0.1; $ATUIN_PREFIX {q} || true"
    )
    [ -n "${selected[1]}" ] && output=${selected[1]}

    echoti smkx

    RBUFFER=""
    LBUFFER=${output}
    zle reset-prompt
    #READLINE_POINT=${#READLINE_LINE}
}

if (( $+commands[atuin] ))
then
  echo "INIT atuin"
  eval "$(atuin init zsh)"

  ATUIN_SESSION=$(atuin uuid)
  export ATUIN_SESSION

  add-zsh-hook preexec _atuin_preexec
  add-zsh-hook precmd _atuin_precmd

  zle -N __atuin_history

  echo "KEY BIND atuin"
  bindkey '^r' __atuin_history
  bindkey '^[[A' __atuin_history
  bindkey '^[OA' __atuin_history
  
fi