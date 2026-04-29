command -v aws >/dev/null 2>&1 || return 1

s3-touch() {
  aws s3 cp \
    --metadata 'touched=touched' \
    --recursive --exclude="*" \
    --cache-control 'no-cache' \
    --include="$2" \
    "${@:3}" \
    "$1" "$1"
}

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