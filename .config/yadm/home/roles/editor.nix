{ config, lib, pkgs, ... }:
let
  cfg = config.profiles;
in
{
  # Example only. Turns on when machine.nix lists "editor".
  config = lib.mkIf (builtins.elem "editor" cfg.roles) {
    programs.helix.enable = true;

    programs.helix.settings.theme = "dark";

    home.packages = lib.optionals (cfg.form == "physical") [
      pkgs.imagemagick
    ];

    home.sessionVariables.EDITOR =
      if cfg.context == "work" then "hx" else "vim";
  };
}
