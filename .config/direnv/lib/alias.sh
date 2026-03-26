alias_dir=${XDG_DATA_HOME:-$HOME/.local/share}/direnv/aliases
rm -rf "$alias_dir"

export_alias() {
  local name=$1
  shift
  local target="$alias_dir/$name"
  mkdir -p "$alias_dir"
  PATH_add "$alias_dir"
  echo "#!/usr/bin/env bash" > "$target"
  echo "$@ \"\$@\"" >> "$target"
  chmod +x "$target"
  1>&2 echo "direnv: export alias +$name"
}
