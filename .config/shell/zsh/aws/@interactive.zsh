s3-touch() {
  aws s3 cp \
    --metadata 'touched=touched' \
    --recursive --exclude="*" \
    --cache-control 'no-cache' \
    --include="$2" \
    "${@:3}" \
    "$1" "$1"
}