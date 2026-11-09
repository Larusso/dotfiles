{ config, lib, pkgs, ... }:
let
  cfg = config.shell.boundary;
in
{
  options.shell.boundary = {
    enable = lib.mkEnableOption "boundary";

    package = lib.mkPackageOption pkgs "boundary" { };

    address = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "BOUNDARY_ADDR. Null skips the export.";
    };

    authMethodId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "AUTH_METHOD_ID. Null skips the export.";
    };

    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Shell aliases defined when this module is enabled.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."shell-hm/zsh/interactive/boundary.zsh".text = ''
      command -v boundary >/dev/null 2>&1 || return 1
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "alias ${name}=${lib.escapeShellArg value}") cfg.aliases)}
      ${lib.optionalString (cfg.address != null) ''
        export BOUNDARY_ADDR="${cfg.address}"
      ''}
      ${lib.optionalString (cfg.authMethodId != null) ''
        export AUTH_METHOD_ID="${cfg.authMethodId}"
      ''}
    '';
  };
}
