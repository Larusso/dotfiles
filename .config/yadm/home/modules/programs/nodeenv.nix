# Home Manager has no nodeenv module. Enabling this installs nodeenv and
# writes NODEENV_ROOT when root is set.
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.nodeenv;
in
{
  options.programs.nodeenv = {
    enable = lib.mkEnableOption "nodeenv";

    package = lib.mkPackageOption pkgs "nodeenv" { };

    enableBashIntegration = lib.hm.shell.mkBashIntegrationOption { inherit config; };

    enableFishIntegration = lib.hm.shell.mkFishIntegrationOption { inherit config; };

    enableZshIntegration = lib.hm.shell.mkZshIntegrationOption { inherit config; };

    rootDirectory = lib.mkOption {
      type = lib.types.path;
      apply = toString;
      default = "${config.xdg.dataHome}/nodeenv";
      defaultText = "\${config.xdg.dataHome}/nodeenv";
      description = ''
        The nodeenv root directory ({env}`NODEENV_ROOT`).

        ::: {.note}
        This deviates from upstream, which uses {file}`$HOME/.nodeenv`.
        The default path in Home Manager is set according to the XDG
        base directory specification.
        :::
      '';
    };
  };

  config = lib.mkIf cfg.enable {
      # Always add the configured `nodeenv` package.
      home.packages = [ cfg.package ];

      programs.bash.initExtra = lib.mkIf cfg.enableBashIntegration ''
        export NODEENV_ROOT="${cfg.rootDirectory}"
        eval "$(${lib.getExe cfg.package} init - bash)"
      '';

      programs.zsh.initContent = lib.mkIf cfg.enableZshIntegration ''
        export NODEENV_ROOT="${cfg.rootDirectory}"
        eval "$(${lib.getExe cfg.package} init - zsh)"
      '';

      programs.fish.interactiveShellInit = lib.mkIf cfg.enableFishIntegration ''
        set -Ux NODEENV_ROOT "${cfg.rootDirectory}"
        ${lib.getExe cfg.package} init - fish | source
      '';
    };
}
