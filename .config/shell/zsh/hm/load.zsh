# Source shell-hm snippets for this stage: posix files, then zsh files.
# Usage: . load.zsh <env|login|interactive>
_xsh_hm_stage=$1
xsh load hm -s posix

_xsh_hm_root="${XDG_CONFIG_HOME:-$HOME/.config}/shell-hm/zsh/${_xsh_hm_stage}"
for _xsh_hm_file in "$_xsh_hm_root"/*.zsh(N); do
  . "$_xsh_hm_file"
done

unset _xsh_hm_stage _xsh_hm_root _xsh_hm_file
