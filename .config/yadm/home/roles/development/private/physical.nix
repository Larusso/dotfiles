{ config, lib, pkgs, ... }:
let
  cfg = config.profiles;
in
{
  config = lib.mkIf (cfg.context == "private" && cfg.form == "physical" && builtins.elem "development" cfg.roles) {
    home.packages = lib.optionals pkgs.stdenv.hostPlatform.isDarwin (with pkgs; [
      softnet
      tart
    ]);
  };
}
