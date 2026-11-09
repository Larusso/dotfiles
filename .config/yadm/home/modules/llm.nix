# llmserve config from ~/.config/llmserve/config.toml.
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.llmserve;
  toml = pkgs.formats.toml { };
in
{
  options.programs.llmserve = {
    enable = lib.mkEnableOption "llmserve config";

    settings = lib.mkOption {
      inherit (toml) type;
      default = { };
      description = "llmserve config.toml contents. Written when this module is enabled.";
    };

    piConfigDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "PI_CODING_AGENT_DIR. Null skips the export.";
    };

    linkDarwinConfigs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "On Darwin, point ~/Library/Application Support/<name> at ~/.config/<name>.";
    };

    package = lib.mkPackageOption pkgs "llmserve" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = {
      "llmserve/config.toml" = lib.mkIf (cfg.settings != { }) {
        source = toml.generate "llmserve-config" cfg.settings;
      };
      "shell-hm/sh/interactive/llm.sh".text = ''
        ${lib.optionalString (cfg.piConfigDir != null) ''
          export PI_CODING_AGENT_DIR="${cfg.piConfigDir}"
        ''}
        ${lib.optionalString (cfg.linkDarwinConfigs != [ ]) ''
          _llm_link_config() {
            _name=$1
            _dest="''${XDG_CONFIG_HOME:-$HOME/.config}/$_name"
            _src="$HOME/Library/Application Support/$_name"
            mkdir -p "$_dest" || return 1
            if [ -L "$_src" ]; then
              return 0
            fi
            if [ -d "$_src" ]; then
              cp -R "$_src/." "$_dest/" || return 1
              mv "$_src" "$_src.pre-xdg" || return 1
            elif [ -e "$_src" ]; then
              echo "llm: $_src exists and is not a directory" >&2
              return 1
            fi
            ln -s "$_dest" "$_src"
          }
          if [ "$(uname -s)" = "Darwin" ]; then
            ${lib.concatMapStrings (name: ''
              _llm_link_config ${lib.escapeShellArg name}
            '') cfg.linkDarwinConfigs}
          fi
          unset -f _llm_link_config
        ''}
      '';
    };
  };
}
