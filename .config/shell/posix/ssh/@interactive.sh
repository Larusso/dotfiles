
#
# SSH configuration module.
#

if [ $(uname -n) != "MAC-1439.local" ]; then
    if ! pgrep -u "$USER" ssh-agent > /dev/null; then
        ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
    fi
    if [[ ! "$SSH_AUTH_SOCK" ]]; then
        source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
    fi
fi

importSSHKey() {
    local temp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'tmpdir')
    local ret_value=0
    cd $temp_dir

    ssh-keygen -K 2> err_output 1> output

    if [ $? == 0 ]
    then
        source_key_name=$(perl -n -e'/id_(.*?)_sk_rk/ && print$1' < output)
        keyname=${1:-"$source_key_name"}

        echo "Moved key id_${source_key_name}_sk_rk to ${HOME}/.ssh/id_${keyname}_sk"
        mv "id_${source_key_name}_sk_rk" "${HOME}/.ssh/id_${keyname}_sk" 
        mv "id_${source_key_name}_sk_rk.pub" "${HOME}/.ssh/id_${keyname}_sk.pub"
    else
        echo $(<err_output)
        ret_value=1
    fi
    cd --
    rm -fr temp_dir
    return $ret_value
}
