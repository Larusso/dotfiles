#
# LLM configuration module.
#

export PI_CODING_AGENT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/pi"

# llmserve and llmfit use dirs::config_dir(). On macOS that is
# ~/Library/Application Support and it ignores XDG_CONFIG_HOME.
# Keep the files under ~/.config and point the Library path at them.
_llm_link_config() {
	_name=$1
	_dest="${XDG_CONFIG_HOME:-$HOME/.config}/$_name"
	_src="$HOME/Library/Application Support/$_name"

	mkdir -p "$_dest" || return 1

	if [ -L "$_src" ]; then
		return 0
	fi

	if [ -d "$_src" ]; then
		cp -R "$_src/." "$_dest/" || {
			echo "llm: could not copy $_src to $_dest" >&2
			return 1
		}
		_backup="$_src.pre-xdg"
		if [ -e "$_backup" ]; then
			_backup="$_src.pre-xdg.$$"
		fi
		mv "$_src" "$_backup" || {
			echo "llm: could not move $_src aside" >&2
			return 1
		}
	elif [ -e "$_src" ]; then
		echo "llm: $_src exists and is not a directory" >&2
		return 1
	fi

	ln -s "$_dest" "$_src" || {
		echo "llm: could not link $_src to $_dest" >&2
		return 1
	}
}

if [ "$(uname -s)" = "Darwin" ]; then
	_llm_link_config llmserve
	_llm_link_config llmfit
fi

unset -f _llm_link_config
unset _name _dest _src _backup
