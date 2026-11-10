# Declares programs.git.sshCommand. programs.git.settings, signing, and
# includes are set by the profile. This writes GIT_SSH_COMMAND when that
# option is set and programs.git.enable is on.
{ config, lib, ... }:
let
  cfg = config.programs.git;
in
{
  options.programs.git.sshCommand = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "GIT_SSH_COMMAND when that file exists. Null skips the export.";
  };

  config = lib.mkIf (cfg.enable && cfg.sshCommand != null) {
    xdg.configFile."shell-hm/sh/env/git.sh".text = ''
      if [ -f "${cfg.sshCommand}" ]; then
        export GIT_SSH_COMMAND="${cfg.sshCommand}"
      else
        echo "Warning: ${cfg.sshCommand} does not exist. GIT_SSH_COMMAND not set."
      fi
    '';
  };
}
