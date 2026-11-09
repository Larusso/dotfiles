{ config, lib, pkgs, ... }:
let
  cfg = config.profiles;
in
{
  imports = [
    ./physical.nix
  ];

  config = lib.mkIf (cfg.context == "work" && builtins.elem "development" cfg.roles) {
    home.packages = with pkgs; [
      graphviz
      jdk
      rustup
    ];
  };
}
