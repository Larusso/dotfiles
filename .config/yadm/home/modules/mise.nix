# programs.mise installs mise. Its shell integration targets the zsh
# module, so the activate line is written for xsh instead.
{ config, lib, ... }:
let
  cfg = config.programs.mise;
in
{
  config = lib.mkIf cfg.enable {
    programs.mise = {
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableNushellIntegration = false;
      enableZshIntegration = false;
    };

    xdg.configFile."shell-hm/zsh/interactive/mise.zsh".text = ''
      eval "$(${lib.getExe cfg.package} activate zsh)"
    '';
  };
}
