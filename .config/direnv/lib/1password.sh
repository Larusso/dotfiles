export_1password_secret_string() {
    local secret_id
    local secret_env_name

    secret_env_name="$1"
    secret_id="$2"

    export "${secret_env_name}"="$(op read "$secret_id")"
}

use_1password_env() {
    local environment_id

    environment_id="$1"
    set -a
    source <(op environment read "$environment_id")
    set +a
}

