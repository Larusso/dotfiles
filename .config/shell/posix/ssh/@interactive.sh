
#
# SSH configuration module.
#

# SSH-Agent will be started by macOS launchD com.openssh.ssh-agent
# We need to start it manually on linux
if [ "$OSTYPE" == "linux-gnu"* ]; then
    if ! pgrep -u "$USER" ssh-agent > /dev/null; then
        ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
    fi
    if [[ ! "$SSH_AUTH_SOCK" ]]; then
        source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
    fi
fi

# listSSHKeys() {
#     setopt PUSHDSILENT
#     set +e 

#     local temp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'tmpdir')
#     local ret_value=0
#     trap "popd; exit" INT
#     pushd $temp_dir
#     ssh-keygen -K 2> err_output 1> output

#     if [ $? == 0 ]
#     then
#         >&2 echo ""
#         >&2 echo "Found Keys:"
#         ls -1 id_* | sed -e "s/\.pub//" | uniq
#     else
#         >&2 echo $(<err_output)
#         ret_value=1
#     fi
#     popd
#     rm -fr temp_dir
#     return $ret_value
# }

# importSSHKey() {
#     setopt PUSHDSILENT
#     set +e 

#     local temp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'tmpdir')
#     local ret_value=0
#     trap "popd; exit 1" INT
#     pushd $temp_dir
#     (trap "popd; exit 1" INT; ssh-keygen -K 2> err_output 1> output)

#     if [ $? == 0 ]
#     then
#         if [ $# -eq 0 ]
#         then
#             >&2 echo "copy all keys"
#             mv -v id_* "${HOME}/.ssh"
#         else
#             for key in "$@"
#             do
#                 mv -v "${key}" "${HOME}/.ssh"
#                 mv -v "${key}.pub" "${HOME}/.ssh"
#             done
#         fi
#     else
#         echo $(<err_output)
#         ret_value=1
#     fi
#     popd
#     rm -fr temp_dir
#     return $ret_value
# }
