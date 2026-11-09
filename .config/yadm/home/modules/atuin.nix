# programs.atuin installs atuin. noBind, historyWidget, and keys are set
# by the profile. Shell integration stays off the zsh module.
{ config, lib, ... }:
let
  cfg = config.programs.atuin;
in
{
  options.programs.atuin = {
    noBind = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set ATUIN_NOBIND so atuin init does not take Ctrl-R.";
    };

    historyWidget = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Bind the custom fzf history widget.";
    };

    keys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Keys bound to the history widget.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableNushellIntegration = false;
      enableZshIntegration = false;
    };

    xdg.configFile."shell-hm/zsh/interactive/atuin.zsh".text = ''
      ${lib.optionalString cfg.noBind ''export ATUIN_NOBIND="true"''}

      ${lib.optionalString cfg.historyWidget ''
        _atuin_preexec() {
          local id; id=$(atuin history start -- "$1")
          export ATUIN_HISTORY_ID="$id"
        }

        _atuin_precmd() {
          local EXIT="$?"
          [[ -z "''${ATUIN_HISTORY_ID}" ]] && return
          (RUST_LOG=error atuin history end --exit "''${EXIT}" -- "''${ATUIN_HISTORY_ID}" &) > /dev/null 2>&1
        }

        __atuin_history() {
          emulate -L zsh
          ATUIN_PREFIX="atuin search --cmd-only"
          INITIAL_QUERY="''${*:-}"
          echoti rmkx
          IFS=: read -rA selected < <(
            FZF_DEFAULT_COMMAND="$ATUIN_PREFIX $(printf %q "$INITIAL_QUERY")" \
            fzf --ansi \
                --disabled --query "$INITIAL_QUERY" \
                --height=50% \
                --bind "change:reload:sleep 0.1; $ATUIN_PREFIX {q} || true"
          )
          [ -n "''${selected[1]}" ] && output=''${selected[1]}
          echoti smkx
          RBUFFER=""
          LBUFFER=''${output}
          zle reset-prompt
        }
      ''}

      if (( $+commands[atuin] )); then
        eval "$(${lib.getExe cfg.package} init zsh)"
        ATUIN_SESSION=$(${lib.getExe cfg.package} uuid)
        export ATUIN_SESSION
        ${lib.optionalString cfg.historyWidget ''
          add-zsh-hook preexec _atuin_preexec
          add-zsh-hook precmd _atuin_precmd
          zle -N __atuin_history
          ${lib.concatMapStrings (key: ''
            bindkey ${lib.escapeShellArg key} __atuin_history
          '') cfg.keys}
        ''}
      fi
    '';
  };
}
