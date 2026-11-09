# programs.gpg installs gnupg. sshSupport is set by the profile and
# chooses the agent behaviour written for interactive shells.
{ config, lib, ... }:
let
  cfg = config.programs.gpg;
in
{
  options.programs.gpg.sshSupport = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Start the agent and point SSH_AUTH_SOCK at it.";
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."shell-hm/sh/interactive/gpg.sh".text = ''
      ensure_gpg_agent_running() {
        if ! pgrep -x "gpg-agent" > /dev/null; then
          gpgconf --launch gpg-agent
        fi
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
        gpg-connect-agent updatestartuptty /bye >/dev/null
      }

      export GPG_TTY=$(tty)
      ${
        if cfg.sshSupport then ''
          ensure_gpg_agent_running
        '' else ''
          gpg-connect-agent updatestartuptty /bye >/dev/null
        ''
      }

      gpgkill() {
        gpg-connect-agent killagent /bye
        gpg-connect-agent updatestartuptty /bye
        gpg-connect-agent /bye
      }

      gpgSerials() {
        gpg-connect-agent "scd serialno" "learn --force" /bye
      }

      gpgImportFromGithub() {
        curl "https://github.com/''${1}.gpg" | gpg --import
      }
    '';
  };
}
