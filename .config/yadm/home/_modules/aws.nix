# programs.awscli installs awscli2 and writes ~/.aws/config from
# programs.awscli.settings. The shell flags are set by the profile.
{ config, lib, ... }:
let
  cfg = config.programs.awscli;
in
{
  options.programs.awscli = {
    ssoBrowser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "AWS_SSO_BROWSER. Null skips the export.";
    };

    saml2aws = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Export saml2aws config and credential paths.";
      };
      configFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "SAML2AWS_CONFIGFILE. Null skips the export.";
      };
      credentialsFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "SAML2AWS_CREDENTIALS_FILE. Null skips the export.";
      };
    };

    s3Touch = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Define the s3-touch helper in interactive zsh.";
    };

    injectCredentialsOnSsh = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Load AWS credentials for ssh commands, then unset them.";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile = lib.mkMerge [
      {
        "shell-hm/sh/env/aws.sh".text = ''
          export AWS_SHARED_CREDENTIALS_FILE="''${XDG_CACHE_HOME:-$HOME/.cache}/aws/credentials"
          ${lib.optionalString (cfg.ssoBrowser != null) ''
            export AWS_SSO_BROWSER="${cfg.ssoBrowser}"
          ''}
          ${lib.optionalString (cfg.saml2aws.enable && cfg.saml2aws.configFile != null) ''
            export SAML2AWS_CONFIGFILE="${cfg.saml2aws.configFile}"
          ''}
          ${lib.optionalString (cfg.saml2aws.enable && cfg.saml2aws.credentialsFile != null) ''
            export SAML2AWS_CREDENTIALS_FILE="${cfg.saml2aws.credentialsFile}"
          ''}
        '';
      }
      (lib.mkIf (cfg.s3Touch || cfg.injectCredentialsOnSsh) {
        "shell-hm/zsh/interactive/aws.zsh".text = ''
          ${lib.optionalString cfg.s3Touch ''
            s3-touch() {
              aws s3 cp \
                --metadata 'touched=touched' \
                --recursive --exclude="*" \
                --cache-control 'no-cache' \
                --include="$2" \
                "''${@:3}" \
                "$1" "$1"
            }
          ''}
          ${lib.optionalString cfg.injectCredentialsOnSsh ''
            _aws_env() {
              aws configure export-credentials --format env 2>/dev/null || true
              local _region
              _region="$(aws configure get region 2>/dev/null)"
              [[ -n "$_region" ]] && printf 'export AWS_REGION=%s\nexport AWS_DEFAULT_REGION=%s\n' "$_region" "$_region"
            }

            _aws_env_injected=0

            _inject_aws_settings_into_environment() {
              if [[ "$1" == ssh* ]]; then
                eval "$(_aws_env)"
                _aws_env_injected=1
              fi
            }

            _cleanup_aws_env() {
              if [[ $_aws_env_injected -eq 1 ]]; then
                unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_CREDENTIAL_EXPIRATION AWS_REGION AWS_DEFAULT_REGION
                _aws_env_injected=0
              fi
            }

            add-zsh-hook preexec _inject_aws_settings_into_environment
            add-zsh-hook precmd _cleanup_aws_env
          ''}
        '';
      })
    ];
  };
}
