{ config, lib, pkgs, unity-version-manager, ... }:
let
  cfg = config.shell.uvm;
in
{
  options.shell.uvm = {
    enable = lib.mkEnableOption "Unity Version Manager";

    package = lib.mkOption {
      type = lib.types.package;
      default = unity-version-manager.packages.${pkgs.stdenv.hostPlatform.system}.uvm;
      description = "uvm package from the Unity Version Manager flake.";
    };

    autoSwitch = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set UVM_AUTO_SWITCH_UNITY_EDITOR.";
    };

    autoInstall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set UVM_AUTO_INSTALL_UNITY_EDITOR.";
    };

    installBase = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "UVM_UNITY_INSTALL_BASE_DIR. Null skips the export.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."shell-hm/sh/env/uvm.sh".text = ''
      #####################################################################################
      # Unity Version Manager                                                             #
      #####################################################################################
      ${lib.optionalString cfg.autoSwitch ''
        export UVM_AUTO_SWITCH_UNITY_EDITOR="YES"''}
      ${lib.optionalString cfg.autoInstall ''
        export UVM_AUTO_INSTALL_UNITY_EDITOR="YES"''}
      ${lib.optionalString (cfg.installBase != null) ''
        export UVM_UNITY_INSTALL_BASE_DIR="${cfg.installBase}"
      ''}
    '';
  };
}
