{ config, lib, pkgs, ... }:
let
  cfg = config.shell.ssh;
in
{
  options.shell.ssh = {
    enable = lib.mkEnableOption "ssh agent on Linux";

    package = lib.mkPackageOption pkgs "openssh" { };

    agentLifetime = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "ssh-agent -t value. Null starts the agent without -t.";
    };

    startAgentOnLinux = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Start ssh-agent when OSTYPE matches linux-gnu and none is running.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = lib.mkIf cfg.startAgentOnLinux {
      "shell-hm/sh/interactive/ssh.sh".text = ''
        if [ "$OSTYPE" == "linux-gnu"* ]; then
          if ! pgrep -u "$USER" ssh-agent > /dev/null; then
            ssh-agent${lib.optionalString (cfg.agentLifetime != null) " -t ${cfg.agentLifetime}"} > "$XDG_RUNTIME_DIR/ssh-agent.env"
          fi
          if [ ! "$SSH_AUTH_SOCK" ]; then
            . "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
          fi
        fi
      '';
    };
  };
}
