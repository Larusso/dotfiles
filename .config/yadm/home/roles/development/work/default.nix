{ config, lib, pkgs, unity-version-manager, ... }:
let
  cfg = config.profiles;
in
{
  imports = [
    ./physical.nix
  ];

  config = lib.mkIf (cfg.context == "work" && builtins.elem "development" cfg.roles) {
    shell.cargo = {
      enable = false;
      name = "Manfred Endres";
      email = "manfred.endres@tslarusso.de";
      vcs = "git";
      sourceEnv = true;
    };

    programs.uvm = {
      enable = true;
      autoSwitch = true;
      autoInstall = true;
      installBase =
        if pkgs.stdenv.hostPlatform.isDarwin then
          "/Applications/Unity/Hub/Editor"
        else
          "${config.home.homeDirectory}/.local/unity";
    };

    home.packages = with pkgs; [
      graphviz
      jdk
      rustup
    ];
  };
}
