#
# Core configuration module.
#

alias reload='exec "$XSHELL"' # reload the current shell configuration

export LANG=en
export PATH=/usr/local/bin:$PATH
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye >/dev/null

alias ls="exa"
alias ll="ls -l"
alias la="ls -la"
alias gradle="gw"

if [[ $TERM == *"kitty" ]]
then
  alias icat="kitty +kitten icat"
  alias d="kitty +kitten diff"
fi


# Add vi customization to less
VLESS=$(find /usr/share/vim -name 'less.sh')
if [ ! -z $VLESS ]; then
	  alias less=$VLESS
fi

gpgkill() {
  gpg-connect-agent killagent /bye
  gpg-connect-agent updatestartuptty /bye
  gpg-connect-agent /bye
}

gg() {
  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]]; then
    git -c color.status=always status --short |
    fzf --exit-0 --height 50% --border --ansi --multi --ansi --nth 2..,.. \
      --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
    cut -c4- | sed 's/.* -> //'
  else
    echo "not in git repo"
    return 1
  fi
}

gcb() {
  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]]; then
    result=$(git branch -a --color=always | grep -v '/HEAD\s' | sort |
    fzf --height 50% --border --ansi --tac --preview-window right:70% \
      --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
    sed 's/^..//' | cut -d' ' -f1)

    if [[ $result != "" ]]; then
      if [[ $result == remotes/* ]]; then
        git checkout --track $(echo $result | sed 's#remotes/##')
      else
        git checkout "$result"
      fi
    fi
  else
    echo "not in git repo"
    return 1
  fi
}

nuke() {
  local pid
  pid=$(ps -ef | grep -v ^root | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}

# shared fzf settings

export FZF_DEFAULT_OPTS='--no-reverse'
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
export FZF_CTRL_T_OPTS="--select-1 --exit-0"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
