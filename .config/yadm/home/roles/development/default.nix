{ config, lib, pkgs, clorthoFor, ... }:
let
  cfg = config.profiles;
in
{
  imports = [
    ./work
    ./private
  ];

  config = lib.mkIf (builtins.elem "development" cfg.roles) {
    home.packages =
      let
        source = clorthoFor cfg.context;
        system = pkgs.stdenv.hostPlatform.system;
      in
      with pkgs; [
        act
        awscli2
        (direnv.overrideAttrs (_: { doCheck = false; }))
        git-crypt
        git-lfs
        jujutsu
        source.packages.${system}.clortho
        source.packages.${system}.gozer
      ];
  };
}
