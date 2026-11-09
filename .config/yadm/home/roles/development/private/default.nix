{ config, lib, ... }:
let
  cfg = config.profiles;
in
{
  imports = [
    ./physical.nix
  ];
}
