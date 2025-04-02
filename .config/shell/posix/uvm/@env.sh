#
# Uvm configuration module.
#

export UVM_AUTO_SWITCH_UNITY_EDITOR="YES"
export UVM_AUTO_INSTALL_UNITY_EDITOR="YES"
current_hostname=$(uname -n)
if [[ "$current_hostname" == "mw-llaruss-C94H" ]] || [[ "$current_hostname" == "mw-mendres-JYJJ" ]]; then
    export UVM_UNITY_INSTALL_BASE_DIR="/Applications/Unity/Hub/Editor"
fi
# TODO figure out where to set this variable?
# Maybe it needs to be host specific

# export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
