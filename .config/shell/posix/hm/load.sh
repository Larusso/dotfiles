# Source the Home Manager snippets for one xsh stage.
# Usage: . load.sh <env|login|interactive>
_xsh_hm_stage=$1
_xsh_hm_root="${XDG_CONFIG_HOME:-$HOME/.config}/shell-hm/sh/${_xsh_hm_stage}"

for _xsh_hm_file in "$_xsh_hm_root"/*.sh; do
  [ -r "$_xsh_hm_file" ] || continue
  . "$_xsh_hm_file"
done

unset _xsh_hm_stage _xsh_hm_root _xsh_hm_file
