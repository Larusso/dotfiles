{ config, lib, pkgs, ... }:
let
  cfg = config.profiles;
in
{
  imports = [
    ./work
    ./private
  ];

  config = lib.mkIf (builtins.elem "development" cfg.roles) {
    home.packages = with pkgs; [
      act
      awscli2
      (direnv.overrideAttrs (_: { doCheck = false; }))
      git-crypt
      git-lfs
      jujutsu
    ];
  };
}
