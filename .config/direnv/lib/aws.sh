export_aws_secret_file() {
    local secret_id
    local secret_file
    local env_name

    env_name="$1"
    secret_id="$2"
    if [ -n "$3" ]; then
      local file_name
      local tmp
      file_name="$3"
      tmp=$(mktemp -d)
      secret_file="${tmp}/${file_name}"
    else
      secret_file=$(mktemp)
    fi

    aws secretsmanager get-secret-value --secret-id "${secret_id}" --output text --query 'SecretBinary' | base64 -D > "${secret_file}"
    export "${env_name}"="${secret_file}"
}

export_aws_secret() {
    local secret_id
    local secret_env_name
    local query

    secret_env_name="$1"
    secret_id="$2"
    query="$3"
    secret=$(aws secretsmanager get-secret-value --secret-id "${secret_id}" --output text --query "${query}")
    export "${secret_env_name}"="${secret}"
}

export_aws_secret_string() {
    export_aws_secret "$1" "$2" "SecretString || SecretBinary"
}

export_aws_secret_username_password() {
    local username_env_name
    local password_env_name
    local secret_id

    username_env_name="$1"
    password_env_name="$2"
    secret_id="$3"

    export "${username_env_name}"="$(aws secretsmanager describe-secret --secret-id "${secret_id}" --output text --query "Tags[?Key=='jenkins:credentials:username'].Value | [0]")"
    export_aws_secret_string "${password_env_name}" "${secret_id}"
}

export_aws_credentials() {
    local secret_id
    local secret_key_id
    local secret_access_key

    secret_id="$1"
    secret_key_id=$(aws secretsmanager describe-secret --secret-id "${secret_id}" --output text --query "Tags[?Key=='jenkins:credentials:username'].Value | [0]")
    secret_access_key=$(aws secretsmanager get-secret-value --secret-id "${secret_id}" --output text --query 'SecretString')

    export AWS_ACCESS_KEY_ID="${secret_key_id}"
    export AWS_SECRET_ACCESS_KEY="${secret_access_key}"
}
