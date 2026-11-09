{ config, lib, pkgs, ... }:
let
  cfg = config.shell.highlighter;
in
{
  options.shell.highlighter = {
    enable = lib.mkEnableOption "zsh syntax highlighting";
    package = lib.mkPackageOption pkgs "zsh-syntax-highlighting" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."shell-hm/zsh/interactive/highlighter.zsh".text = ''
      source ${cfg.package}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    '';
  };
}
