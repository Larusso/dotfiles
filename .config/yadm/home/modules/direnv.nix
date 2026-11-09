# programs.direnv installs direnv and writes direnv.toml from
# programs.direnv.config, which the profile sets. Shell integration stays
# off the zsh and bash modules; the hook is written for xsh to source.
{ config, lib, ... }:
let
  cfg = config.programs.direnv;
  hook = shell: ''
    if ! command -v direnv >/dev/null 2>&1; then
      return 1
    fi
    direnv_cache="$XDG_CACHE_HOME/direnv/hook.${shell}"
    if [ ! -s "$direnv_cache" ] || [ "$(command -v direnv)" -nt "$direnv_cache" ]; then
      mkdir -p "$(dirname "$direnv_cache")"
      direnv hook ${shell} > "$direnv_cache"
    fi
    . "$direnv_cache"
    unset direnv_cache
  '';
in
{
  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableNushellIntegration = false;
      enableZshIntegration = false;
    };

    xdg.configFile = {
      "shell-hm/zsh/interactive/direnv.zsh".text = hook "zsh";
      "shell-hm/bash/interactive/direnv.bash".text = hook "bash";
    };
  };
}
