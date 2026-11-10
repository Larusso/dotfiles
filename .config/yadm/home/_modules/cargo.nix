{ config, lib, pkgs, ... }:
let
  cfg = config.shell.cargo;
in
{
  options.shell.cargo = {
    enable = lib.mkEnableOption "cargo and rustup shell setup";

    package = lib.mkPackageOption pkgs "rustup" { };

    name = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "CARGO_NAME and CARGO_CARGO_NEW_NAME. Null skips them.";
    };

    email = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "CARGO_EMAIL and CARGO_CARGO_NEW_EMAIL. Null skips them.";
    };

    vcs = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "CARGO_CARGO_NEW_VCS. Null skips it.";
    };

    sourceEnv = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Source $CARGO_HOME/env when that file exists.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."shell-hm/zsh/interactive/cargo.zsh".text = ''
      export RUSTUP_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}/rustup"
      export CARGO_HOME="''${XDG_LIB_HOME:-$HOME/.local/lib}/cargo"
      ${lib.optionalString cfg.sourceEnv ''
        if [ ! -f "$CARGO_HOME/env" ]; then
          return 1
        fi
        source "$CARGO_HOME/env"
      ''}
      ${lib.optionalString (cfg.name != null) ''
        export CARGO_NAME="${cfg.name}"
        export CARGO_CARGO_NEW_NAME="${cfg.name}"
      ''}
      ${lib.optionalString (cfg.email != null) ''
        export CARGO_EMAIL="${cfg.email}"
        export CARGO_CARGO_NEW_EMAIL="${cfg.email}"
      ''}
      ${lib.optionalString (cfg.vcs != null) ''
        export CARGO_CARGO_NEW_VCS="${cfg.vcs}"
      ''}
    '';
  };
}
