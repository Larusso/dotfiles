# programs.rbenv installs rbenv. Shell integration stays off the zsh
# module; RBENV_ROOT is written for xsh when root is set.
{ config, lib, ... }:
let
  cfg = config.programs.rbenv;
in
{
  options.programs.rbenv.root = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "RBENV_ROOT. Null skips the export.";
  };

  config = lib.mkIf cfg.enable {
    programs.rbenv = {
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };

    xdg.configFile = lib.mkIf (cfg.root != null) {
      "shell-hm/sh/env/rbenv.sh".text = ''
        export RBENV_ROOT="${cfg.root}"
      '';
    };
  };
}
