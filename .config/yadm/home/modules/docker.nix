{ config, lib, pkgs, ... }:
let
  cfg = config.shell.docker;
in
{
  options.shell.docker = {
    enable = lib.mkEnableOption "DOCKER_HOST";

    package = lib.mkPackageOption pkgs "docker-client" { };

    host = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Value of DOCKER_HOST. Null skips the export.";
    };

    linuxOnly = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Export DOCKER_HOST only when OSTYPE matches linux-gnu.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = lib.mkIf (cfg.host != null) {
      "shell-hm/sh/env/docker.sh".text =
        if cfg.linuxOnly then ''
          if [ "$OSTYPE" == "linux-gnu"* ]; then
            export DOCKER_HOST="${cfg.host}"
          fi
        '' else ''
          export DOCKER_HOST="${cfg.host}"
        '';
    };
  };
}
