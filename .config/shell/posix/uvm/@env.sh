#
# Uvm configuration module.
#

export UVM_AUTO_SWITCH_UNITY_EDITOR="YES"
export UVM_AUTO_INSTALL_UNITY_EDITOR="YES"
if [[ "$(yadm config local.class 2>/dev/null)" == "work-primary" ]]; then
    export UVM_UNITY_INSTALL_BASE_DIR="/Applications/Unity/Hub/Editor"
fi

# export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
