# Example of a module Home Manager does not ship.
# A role turns it on:
#
#   programs.exampleTool = {
#     enable = true;
#     settings.greeting = "hello";
#   };
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.exampleTool;
in
{
  options.programs.exampleTool = {
    enable = lib.mkEnableOption "example-tool";

    package = lib.mkPackageOption pkgs "hello" { };

    settings = lib.mkOption {
      type = lib.types.submodule {
        options.greeting = lib.mkOption {
          type = lib.types.str;
          default = "hello";
          description = "Value written into the example-tool config.";
        };
      };
      default = { };
      description = "Values written to the example-tool config file.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."example-tool/config".text = lib.generators.toINI { } {
      main = {
        greeting = cfg.settings.greeting;
      };
    };
  };
}
