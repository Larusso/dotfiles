{ lib, ... }:

{
  # Values are written by yadm alt into machine.nix. Role modules read them
  # and enable themselves with lib.mkIf. No packages are installed from here yet.
  options.profiles = {
    context = lib.mkOption {
      type = lib.types.enum [ "work" "private" ];
      description = "Machine context chosen during yadm bootstrap.";
    };

    form = lib.mkOption {
      type = lib.types.enum [ "physical" "vm" ];
      description = "Machine type chosen during yadm bootstrap.";
    };

    roles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Role names chosen during yadm bootstrap.";
    };
  };
}
