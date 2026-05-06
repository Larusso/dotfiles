#
# Uvm configuration module.
#

export UVM_AUTO_SWITCH_UNITY_EDITOR="YES"
export UVM_AUTO_INSTALL_UNITY_EDITOR="YES"
if yadm config --get-all local.class 2>/dev/null | grep -qx "work"; then
    export UVM_UNITY_INSTALL_BASE_DIR="/Applications/Unity/Hub/Editor"
fi

# export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
