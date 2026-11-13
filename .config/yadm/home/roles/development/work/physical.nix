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
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };

    programs.rbenv = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };

    # programs.jenv = {
    #   enable = true;
    #   enableBashIntegration = false;
    #   enableFishIntegration = false;
    #   enableZshIntegration = false;
    # };

    programs.nodeenv = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };

    home.packages = with pkgs; [
      boundary
      gradle
    ];
  };
}
