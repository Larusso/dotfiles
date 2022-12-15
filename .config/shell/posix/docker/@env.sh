#
# Docker configuration module for posix.
#

if [ "$OSTYPE" == "linux-gnu"* ]; then
	export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
fi
