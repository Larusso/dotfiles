# programs.fzf installs fzf. Widget options are set by the profile.
# Shell integration stays off the zsh and bash modules; the snippet below
# is what xsh sources once programs.fzf.enable is on.
{ config, lib, ... }:
let
  cfg = config.programs.fzf;
  opts = name: value:
    lib.optionalString (value != [ ]) ''
      export ${name}="${lib.concatStringsSep " " value}"
    '';
in
{
  options.programs.fzf = {
    keyBindings = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Source fzf key bindings in interactive shells.";
    };

    completion = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Source fzf completion in interactive shells.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.fzf = {
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableNushellIntegration = false;
      enableZshIntegration = false;
    };

    xdg.configFile = lib.mkMerge [
      {
        "shell-hm/sh/env/fzf.sh".text = ''
          ${opts "FZF_DEFAULT_OPTS" cfg.defaultOptions}
          ${opts "FZF_CTRL_T_OPTS" cfg.fileWidget.options}
          ${opts "FZF_CTRL_R_OPTS" cfg.historyWidget.options}
          ${opts "FZF_ALT_C_OPTS" cfg.changeDirWidget.options}
        '';
      }
      (lib.mkIf (cfg.keyBindings || cfg.completion) {
        "shell-hm/zsh/interactive/fzf.zsh".text = ''
          if [[ $options[zle] = on ]]; then
            ${lib.optionalString cfg.keyBindings "source ${cfg.package}/share/fzf/key-bindings.zsh"}
            ${lib.optionalString cfg.completion "source ${cfg.package}/share/fzf/completion.zsh"}
          fi
        '';
        "shell-hm/bash/interactive/fzf.bash".text = ''
          if [[ :$SHELLOPTS: =~ :(vi|emacs): ]]; then
            ${lib.optionalString cfg.keyBindings "source ${cfg.package}/share/fzf/key-bindings.bash"}
            ${lib.optionalString cfg.completion "source ${cfg.package}/share/fzf/completion.bash"}
          fi
        '';
      })
    ];
  };
}
