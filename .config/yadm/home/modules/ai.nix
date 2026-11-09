# Path flags for the safehouse wrappers. The wrapper functions still live
# in shell/posix/ai/@interactive.sh. Exports from these flags are applied
# before that file is sourced, and that file keeps a value that is already set.
{ config, lib, ... }:
let
  cfg = config.shell.ai;
  profile = name: value:
    lib.optionalString (value != null) ''
      export ${name}="${value}"
    '';
in
{
  options.shell.ai = {
    enable = lib.mkEnableOption "safehouse profile paths and command wrappers";

    workBase = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "WORK_BASE. Null skips the export.";
    };

    profiles = {
      localOverrides = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      cargo = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      claude = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      codex = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      cursor = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      gemini = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      nix = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      dotnet = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      docker = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };

    commandWrappers = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Define safe, claude, codex, cursor-agent, and gemini.";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."shell-hm/sh/interactive/ai.sh".text = ''
      ${profile "SAFEHOUSE_PROFILE_LOCAL_OVERRIDES" cfg.profiles.localOverrides}
      ${profile "SAFEHOUSE_PROFILE_CARGO" cfg.profiles.cargo}
      ${profile "SAFEHOUSE_PROFILE_CLAUDE" cfg.profiles.claude}
      ${profile "SAFEHOUSE_PROFILE_CODEX" cfg.profiles.codex}
      ${profile "SAFEHOUSE_PROFILE_CURSOR" cfg.profiles.cursor}
      ${profile "SAFEHOUSE_PROFILE_GEMINI" cfg.profiles.gemini}
      ${profile "SAFEHOUSE_PROFILE_NIX" cfg.profiles.nix}
      ${profile "SAFEHOUSE_PROFILE_DOTNET" cfg.profiles.dotnet}
      ${profile "SAFEHOUSE_PROFILE_DOCKER" cfg.profiles.docker}
      ${lib.optionalString (cfg.workBase != null) ''
        export WORK_BASE="${cfg.workBase}"
      ''}
      ${lib.optionalString cfg.commandWrappers ''
        . ${config.home.homeDirectory}/.config/shell/posix/ai/@interactive.sh
      ''}
    '';
  };
}
