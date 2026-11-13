{ config, lib, pkgs, ... }:
let
  cfg = config.profiles;
in
{
  config = lib.mkIf (cfg.form == "physical" ) {
    programs._1password.installUI = true;
  };
}
