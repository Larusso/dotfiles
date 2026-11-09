{ config, lib, pkgs, ... }:
let
  cfg = config.profiles;
in
{
  config = lib.mkIf (cfg.context == "work" && cfg.form == "physical" && builtins.elem "development" cfg.roles) {
    programs.gradle = {
      enable = false;
      home = ".cache/gradle";
    };

    shell.boundary = {
      enable = false;
      address = "https://boundary.playticorp.com/";
      authMethodId = "amoidc_P4805BEdcS";
      aliases = {
        bsh = "boundary connect ssh";
        bauth = "boundary authenticate oidc";
      };
    };

    programs.pyenv = {
      enable = false;
      root = "\${XDG_DATA_HOME:-$HOME/.local/share}/pyenv";
    };

    programs.rbenv = {
      enable = false;
      root = "\${XDG_DATA_HOME:-$HOME/.local/share}/rbenv";
    };

    shell.jenv = {
      enable = false;
      root = "\${XDG_DATA_HOME:-$HOME/.local/share}/jenv";
    };

    shell.nodenv = {
      enable = false;
      root = "\${XDG_DATA_HOME:-$HOME/.local/share}/nodenv";
    };

    home.packages = with pkgs; [
      boundary
      gradle
      nodeenv
      pyenv
      rbenv
    ];
  };
}
