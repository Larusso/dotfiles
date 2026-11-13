# Home Manager has no jenv module. Enabling this installs jenv and
# writes JENV_ROOT when root is set.
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.jenv;
in
{
  options.programs.jenv = {
    enable = lib.mkEnableOption "jenv";

    package = lib.mkPackageOption pkgs "jenv" { };

    enableBashIntegration = lib.hm.shell.mkBashIntegrationOption { inherit config; };

    enableFishIntegration = lib.hm.shell.mkFishIntegrationOption { inherit config; };

    enableZshIntegration = lib.hm.shell.mkZshIntegrationOption { inherit config; };

    rootDirectory = lib.mkOption {
      type = lib.types.path;
      apply = toString;
      default = "${config.xdg.dataHome}/jenv";
      defaultText = "\${config.xdg.dataHome}/jenv";
      description = ''
        The jenv root directory ({env}`JENV_ROOT`).

        ::: {.note}
        This deviates from upstream, which uses {file}`$HOME/.jenv`.
        The default path in Home Manager is set according to the XDG
        base directory specification.
        :::
      '';
    };
  };

  config = lib.mkIf cfg.enable {
      # Always add the configured `jenv` package.
      home.packages = [ cfg.package ];

      programs.bash.initExtra = lib.mkIf cfg.enableBashIntegration ''
        export JENV_ROOT="${cfg.rootDirectory}"
        eval "$(${lib.getExe cfg.package} init - bash)"
      '';

      programs.zsh.initContent = lib.mkIf cfg.enableZshIntegration ''
        export JENV_ROOT="${cfg.rootDirectory}"
        eval "$(${lib.getExe cfg.package} init - zsh)"
      '';

      programs.fish.interactiveShellInit = lib.mkIf cfg.enableFishIntegration ''
        set -Ux JENV_ROOT "${cfg.rootDirectory}"
        ${lib.getExe cfg.package} init - fish | source
      '';
    };
}
