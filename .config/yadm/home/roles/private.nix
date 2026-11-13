{ config, lib, pkgs, ... }:
let
  cfg = config.profiles;
in
{
  config = lib.mkIf (cfg.context == "private") {
    programs._1password.sshAgentConfig = {
      ssh-keys = [
        {
          item = "cfab47ctgidp3ofgaj2r5s37nq";
          vault = "qws2fge5tqje77rrw2m563w5fy";
        }
        {
          item = "upujkb52no4ec5uzjw4beipilu";
          vault = "qws2fge5tqje77rrw2m563w5fy";
        }
      ];
    };
  };
}
