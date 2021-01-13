#
# Core configuration module.
#
# Detect the platform (similar to $OSTYPE)
OS="`uname`"
case $OS in
  'Linux')
    OS='Linux'
    ;;
  'WindowsNT')
    OS='Windows'
    ;;
  'Darwin') 
    OS='macOS'
    ;;
  *) ;;
esac

export LANG=en
export PATH=/usr/local/bin:$PATH

if [ "$OS" = "macOS" ]; then
    export GPG_TTY="$(tty)"
fi

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye >/dev/null
