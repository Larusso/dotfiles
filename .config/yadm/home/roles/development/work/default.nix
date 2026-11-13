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

    programs._1password.sshAgentConfig = {
      ssh-keys = [
        {
          # This needs to be fixed
          item = "cfab47ctgidp3ofgaj2r5s37nq";
          vault = "qws2fge5tqje77rrw2m563w5fy";
        }
        {
          item = "u3gswvnnn2n3edir6i4nx34mga";
          vault = "qws2fge5tqje77rrw2m563w5fy";
        }
        {
          item = "rgjb4uiaha2mw7jq4gar6wgvmy";
          vault = "mjyal2admd3wecshhjomaobfta";
        }
        {
          item = "rduz43k7eol7ei5uewepkfigku";
          vault = "mjyal2admd3wecshhjomaobfta";
        }
        {
          item = "ytdlviensxjcozev2i7i7hcqgi";
          vault = "mjyal2admd3wecshhjomaobfta";
        }
      ];
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
