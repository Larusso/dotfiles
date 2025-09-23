#
# Core configuration module.
#

alias reload='exec "$XSHELL"' # reload the current shell configuration

alias ls="eza"
alias vim="nvim"
alias ll="ls -l"
alias la="ls -la"
alias gradle="gw"
alias gg="git status -s"
alias kkk='vim $(fzf --preview="bat --color=always {}")'
if [[ $TERM == *"kitty" ]]; then
  alias icat="kitty +kitten icat"
  alias d="kitty +kitten diff"
  alias ssh="kitty +kitten ssh"
fi

# Add vi customization to less
VLESS=$(find /usr/share/vim -name 'less.sh')
if [ ! -z $VLESS ]; then
  alias less=$VLESS
fi

ggf() {
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

  if [ "x$pid" != "x" ]; then
    echo $pid | xargs kill -${1:-9}
  fi
}

print-path() {
  echo "$PATH" | tr ':' '\n'
}

fenv() {
  local key
  key=$(env | cut -d= -f1 | fzf \
    --height 50% \
    --ignore-case \
    --prompt="Select env var: ") || return
  env | grep -m1 "^${key}=" || echo "$key is not set"
}

fenvp() {
  env | cut -d= -f1 | fzf \
    --height 50% \
    --border \
    --prompt="Select env var: " \
    --ignore-case \
    --preview='bash -c "printenv {}"' \
    --preview-window=right:70% \
    --bind "enter:execute-silent(echo {}=${!})+abort"
}

remote-shell() {
  local conn="$1"
  shift

  local profile="${AWS_PROFILE:-atlas}"
  local saml_cred_file="$HOME/.cache/saml2aws/credentials"
  local credfile

  # Use SAML credentials file if it exists
  if [[ -f "$saml_cred_file" ]]; then
    credfile="$saml_cred_file"
  else
    credfile="$HOME/.aws/credentials"
  fi

  # Helper to read from chosen credentials file
  get_aws_cred() {
    AWS_SHARED_CREDENTIALS_FILE="$credfile" aws configure get "$1" --profile "$profile"
  }

  local access_key="${AWS_ACCESS_KEY_ID:-$(get_aws_cred aws_access_key_id)}"
  local secret_key="${AWS_SECRET_ACCESS_KEY:-$(get_aws_cred aws_secret_access_key)}"
  local session_token="${AWS_SESSION_TOKEN:-$(get_aws_cred aws_session_token)}"
  local region="${AWS_REGION:-$(get_aws_cred region)}"

  if [[ -z "$access_key" || -z "$secret_key" ]]; then
    echo "❌ AWS credentials not found for profile '$profile'" >&2
    return 1
  fi

  ssh -t "$conn" \
    "ATLAS_READ_USR='$ATLAS_READ_USR' \
     ATLAS_READ_PSW='$ATLAS_READ_PSW' \
     AWS_ACCESS_KEY_ID='$access_key' \
     AWS_SECRET_ACCESS_KEY='$secret_key' \
     AWS_SESSION_TOKEN='$session_token' \
     AWS_REGION='$region' \
     AWS_DEFAULT_REGION='$region' \
     exec \$SHELL -l"
}

if command -v neovide >/dev/null 2>&1; then
  neo() {
    OPENAI_API_KEY=$(security find-generic-password -a "$USER" -s "OPENAI_NEOVIM_API_KEY" -w 2>/dev/null) command neovide "$@" &
    disown
  }
fi

# shared fzf settings

export FZF_DEFAULT_OPTS='--no-reverse'
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
export FZF_CTRL_T_OPTS="--select-1 --exit-0"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree {} | head -200'"
