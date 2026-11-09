{ config, lib, pkgs, ... }:
let
  cfg = config.profiles;
in
{
  config = lib.mkIf (cfg.context == "work" && cfg.form == "physical" && builtins.elem "development" cfg.roles) {
    home.packages = with pkgs; [
      boundary
      gradle
      nodeenv
      pyenv
      rbenv
    ];
  };
}
