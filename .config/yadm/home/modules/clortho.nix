# clortho and gozer come from the work or private flake, selected by
# profiles.context. Home Manager has no module for them.
{ config, lib, pkgs, clorthoFor, ... }:
let
  cfg = config.programs.clortho;
  source = clorthoFor config.profiles.context;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.programs.clortho = {
    enable = lib.mkEnableOption "clortho";

    package = lib.mkOption {
      type = lib.types.package;
      default = source.packages.${system}.clortho;
      description = "clortho package for this machine's context.";
    };

    gozer = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Also install gozer from the same flake.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = source.packages.${system}.gozer;
      };
    };

    seatbeltDebug = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Define seatbelt_debug.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ] ++ lib.optional cfg.gozer.enable cfg.gozer.package;

    xdg.configFile."shell-hm/sh/interactive/clortho.sh".text = ''
      command -v clortho >/dev/null 2>&1 || return 1
      eval "$(command clortho init)"
      ${lib.optionalString cfg.seatbeltDebug ''
        seatbelt_debug() {
          /usr/bin/log stream \
            --style compact \
            --predicate 'eventMessage CONTAINS "Sandbox:" AND eventMessage CONTAINS "deny("'
        }
      ''}
    '';
  };
}
