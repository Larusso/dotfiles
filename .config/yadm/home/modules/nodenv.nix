# Home Manager has no nodenv module. Enabling this installs nodenv.
# The exported name is NODEENV_ROOT, matching shell/posix/env/@env.sh.
{ config, lib, pkgs, ... }:
let
  cfg = config.shell.nodenv;
in
{
  options.shell.nodenv = {
    enable = lib.mkEnableOption "nodenv";

    package = lib.mkPackageOption pkgs "nodenv" { };

    root = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "NODEENV_ROOT. Null skips the export.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = lib.mkIf (cfg.root != null) {
      "shell-hm/sh/env/nodenv.sh".text = ''
        export NODEENV_ROOT="${cfg.root}"
      '';
    };
  };
}
