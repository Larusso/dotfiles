# Home Manager has no jenv module. Enabling this installs jenv and
# writes JENV_ROOT when root is set.
{ config, lib, pkgs, ... }:
let
  cfg = config.shell.jenv;
in
{
  options.shell.jenv = {
    enable = lib.mkEnableOption "jenv";

    package = lib.mkPackageOption pkgs "jenv" { };

    root = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "JENV_ROOT. Null skips the export.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = lib.mkIf (cfg.root != null) {
      "shell-hm/sh/env/jenv.sh".text = ''
        export JENV_ROOT="${cfg.root}"
      '';
    };
  };
}
