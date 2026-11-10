# programs.powerlevel10k writes the prompt files from the settings the
# profile assigns. Enabling the module is what installs the package.
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.powerlevel10k;

  quote = value:
    if value == true then "true"
    else if value == false then "false"
    else if value == "" then ""
    else "'${lib.replaceStrings [ "'" ] [ "'\\''" ] (toString value)}'";

  render = name: value:
    if builtins.isList value then
      "typeset -g ${name}=(\n${lib.concatMapStrings (item: "    ${item}\n") value})"
    else
      "typeset -g ${name}=${quote value}";

  renderSet = settings:
    lib.concatStringsSep "\n" (lib.mapAttrsToList render settings);

  configFile = name: settings: sshSettings: formatter: ''
    () {
      emulate -L zsh
      unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
      ${lib.optionalString (formatter != "") ''
        function my_git_formatter() {
        ${formatter}
        }
        functions -M my_git_formatter 2>/dev/null
      ''}
      ${renderSet settings}
      ${lib.optionalString (sshSettings != { }) ''
        if [[ -n ''${SSH_CONNECTION:-}''${SSH_CLIENT:-}''${SSH_TTY:-} ]]; then
        ${renderSet sshSettings}
        fi
      ''}
      (( ! $+functions[p10k] )) || p10k reload
    }
  '';
in
{
  options.programs.powerlevel10k = {
    enable = lib.mkEnableOption "powerlevel10k";

    package = lib.mkPackageOption pkgs "zsh-powerlevel10k" { };

    instantPrompt = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Source the instant prompt before the theme.";
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf (lib.types.oneOf [ lib.types.bool lib.types.str (lib.types.listOf lib.types.str) ]);
      default = { };
      description = "POWERLEVEL9K settings written to the generated prompt config.";
      example = {
        POWERLEVEL9K_MODE = "nerdfont-complete";
        POWERLEVEL9K_LEFT_PROMPT_ELEMENTS = [ "dir" "vcs" "newline" "prompt_char" ];
        POWERLEVEL9K_PROMPT_ADD_NEWLINE = true;
      };
    };

    sshSettings = lib.mkOption {
      type = lib.types.attrsOf (lib.types.oneOf [ lib.types.bool lib.types.str (lib.types.listOf lib.types.str) ]);
      default = { };
      description = "POWERLEVEL9K settings applied only in an SSH session.";
    };

    gitFormatter = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Body of my_git_formatter(), included when non-empty.";
    };

    linux = {
      settings = lib.mkOption {
        type = lib.types.attrsOf (lib.types.oneOf [ lib.types.bool lib.types.str (lib.types.listOf lib.types.str) ]);
        default = { };
        description = "Prompt settings used when TERM is linux.";
      };
      sshSettings = lib.mkOption {
        type = lib.types.attrsOf (lib.types.oneOf [ lib.types.bool lib.types.str (lib.types.listOf lib.types.str) ]);
        default = { };
      };
      gitFormatter = lib.mkOption {
        type = lib.types.lines;
        default = "";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = {
      "zsh/p10k.zsh".text = configFile "p10k" cfg.settings cfg.sshSettings cfg.gitFormatter;
      "zsh/p10k-linux.zsh".text = configFile "p10k-linux" cfg.linux.settings cfg.linux.sshSettings cfg.linux.gitFormatter;
      "shell-hm/zsh/interactive/powerlevel10k.zsh".text = ''
        ${lib.optionalString cfg.instantPrompt ''
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p9k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p9k-instant-prompt-''${(%):-%n}.zsh"
          fi
        ''}
        source ${cfg.package}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        if [ "$TERM" = "linux" ]; then
          source ${config.xdg.configHome}/zsh/p10k-linux.zsh
        else
          source ${config.xdg.configHome}/zsh/p10k.zsh
        fi
      '';
    };
  };
}
