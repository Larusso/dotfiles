# programs.pyenv installs pyenv. Shell integration stays off the zsh
# module; PYENV_ROOT is written for xsh when root is set.
{ config, lib, ... }:
let
  cfg = config.programs.pyenv;
in
{
  options.programs.pyenv.root = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "PYENV_ROOT. Null skips the export.";
  };

  config = lib.mkIf cfg.enable {
    programs.pyenv = {
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };

    xdg.configFile = lib.mkIf (cfg.root != null) {
      "shell-hm/sh/env/pyenv.sh".text = ''
        export PYENV_ROOT="${cfg.root}"
      '';
    };
  };
}
