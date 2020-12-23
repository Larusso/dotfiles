#
# Core configuration module.
#

alias reload='exec "$XSHELL"' # reload the current shell configuration

alias ls=exa
alias ll=ls -l
alias la=ls -la

export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

