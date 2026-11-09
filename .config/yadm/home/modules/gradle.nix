# programs.gradle installs gradle and sets GRADLE_USER_HOME when home
# is not the default. The login snippet is there for xsh to source.
{ config, lib, ... }:
let
  cfg = config.programs.gradle;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."shell-hm/zsh/login/gradle.zsh".text = ''
      export GRADLE_USER_HOME="${config.home.homeDirectory}/${cfg.home}"
    '';
  };
}
