{ config, lib, ... }:
let
  cfg = config.shell.vimMode;
in
{
  options.shell.vimMode = {
    enable = lib.mkEnableOption "zsh vim mode";

    plugin = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Plugin file to source. Nixpkgs has no package for this checkout.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.plugin != null) {
    xdg.configFile."shell-hm/zsh/interactive/vim-mode.zsh".text = ''
      source "${cfg.plugin}"
    '';
  };
}
