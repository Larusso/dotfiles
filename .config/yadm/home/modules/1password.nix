# programs._1password installs the app when enabled. sshAgentConfig is
# the contents of ~/.config/1password/ssh/agent.toml and is set by the profile.
{ config, lib, pkgs, ... }:
let
  cfg = config.programs._1password;
  toml = pkgs.formats.toml { };
in
{
  options.programs._1password = {
    enable = lib.mkEnableOption "1Password";

    installCLI = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install the 1Password CLI.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs._1password-gui;
      description = "1Password GUI package.";
    };

    cliPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs._1password-cli;
      description = "1Password CLI package.";
    };

    sshAgentConfig = lib.mkOption {
      inherit (toml) type;
      default = { };
      description = "Contents of ~/.config/1password/ssh/agent.toml.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = [ cfg.package ] ++ lib.optional cfg.installCLI cfg.cliPackage;
    })
    (lib.mkIf (cfg.sshAgentConfig != { }) {
      xdg.configFile."1password/ssh/agent.toml".source =
        toml.generate "1password-ssh-agent" cfg.sshAgentConfig;
    })
  ];
}
