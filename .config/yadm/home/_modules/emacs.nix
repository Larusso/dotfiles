{ config, lib, pkgs, ... }:
let
  cfg = config.shell.emacs;
in
{
  options.shell.emacs = {
    enable = lib.mkEnableOption "emacs PATH entry and emax helper";

    package = lib.mkPackageOption pkgs "emacs" { };

    userBin = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Directory appended to PATH in login shells. Null skips it.";
    };

    emax = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Define the emax helper in interactive shells.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = lib.mkMerge [
      (lib.mkIf (cfg.userBin != null) {
        "shell-hm/sh/login/emacs.sh".text = ''
          export PATH="$PATH:${cfg.userBin}"
        '';
      })
      (lib.mkIf cfg.emax {
        "shell-hm/sh/interactive/emacs.sh".text = ''
          emax() {
            $(emacs "$@") & >/dev/null
          }
        '';
      })
    ];
  };
}
