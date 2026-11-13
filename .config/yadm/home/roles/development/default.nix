{ config, lib, pkgs, clorthoFor, ... }:
let
  cfg = config.profiles;
  direnv = pkgs.direnv.overrideAttrs (_: {
    doCheck = false;
  });
  source = clorthoFor cfg.context;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [
    ./work
    ./private
  ];

  config = lib.mkIf (builtins.elem "development" cfg.roles) {
    programs.direnv = {
      enable = false;
      package = direnv;
      config.global = {
        warn_timeout = "1m";
        hide_env_diff = true;
      };
    };

    programs.awscli = {
      enable = false;
      ssoBrowser = "/Applications/Safari.app/Contents/MacOS/Safari";
      s3Touch = true;
      injectCredentialsOnSsh = true;
      saml2aws = {
        enable = true;
        configFile = "\${XDG_CONFIG_HOME:-$HOME/.config}/saml2aws/config";
        credentialsFile = "\${XDG_CACHE_HOME:-$HOME/.cache}/saml2aws/credentials";
      };
      settings = {
        "profile corp-it-admin-sso" = {
          sso_session = "wooga";
          sso_account_id = "314686155708";
          sso_role_name = "AdministratorAccess";
        };
        "profile atlas-admin-sso" = {
          sso_session = "wooga";
          sso_account_id = "853684859681";
          sso_role_name = "AdministratorAccess";
          region = "eu-central-1";
        };
        "profile ai-engineering-admin-sso" = {
          sso_session = "wooga";
          sso_account_id = "845517756186";
          sso_role_name = "AdministratorAccess";
          region = "eu-central-1";
        };
        "profile ai-engineering-poweruser-sso" = {
          sso_session = "wooga";
          sso_account_id = "845517756186";
          sso_role_name = "PowerUserAccess";
          region = "eu-central-1";
        };
        "profile atlas-admin" = {
          credential_process = "${config.home.homeDirectory}/.local/bin/aws-sso-creds atlas-admin-sso";
          region = "eu-central-1";
        };
        "profile default" = {
          credential_process = "${config.home.homeDirectory}/.local/bin/aws-sso-creds atlas-admin-sso";
          region = "eu-central-1";
        };
        "profile corp-it-admin" = {
          credential_process = "${config.home.homeDirectory}/.local/bin/aws-sso-creds corp-it-admin-sso";
          region = "eu-central-1";
        };
        "profile ai-engineering-admin" = {
          credential_process = "${config.home.homeDirectory}/.local/bin/aws-sso-creds ai-engineering-admin-sso";
          region = "eu-central-1";
        };
        "profile ai-engineering" = {
          credential_process = "${config.home.homeDirectory}/.local/bin/aws-sso-creds ai-engineering-admin-sso";
          region = "eu-central-1";
        };
        "profile shs" = {
          role_arn = "arn:aws:iam::471112723539:role/ai-stream-team";
          source_profile = "ai-engineering";
          region = "eu-west-1";
        };
        "profile ai-engineering-runner" = {
          role_arn = "arn:aws:iam::845517756186:role/terraform-runner";
          source_profile = "ai-engineering";
          role_session_name = "local";
          region = "eu-central-1";
        };
        "profile tool-publish" = {
          role_arn = "arn:aws:iam::845517756186:role/tool-publish";
          source_profile = "ai-engineering-admin";
          region = "eu-central-1";
        };
        "sso-session wooga" = {
          sso_start_url = "https://identitycenter.amazonaws.com/ssoins-66841292f85cd78c";
          sso_region = "us-east-2";
          sso_registration_scopes = "sso:account:access";
        };
      };
    };

    programs.clortho = {
      enable = true;
      gozer.enable = true;
      seatbeltDebug = true;
    };

    programs.git.lfs.enable = true;

    home.packages = [
      pkgs.act
      pkgs.awscli2
      direnv
      pkgs.git-crypt
      pkgs.git-lfs
      pkgs.jujutsu
    ];
  };
}
