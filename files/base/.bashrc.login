# Open proper shell on Windows subsystem
if [ -n "${BASH_VERSION-}" ] && grep -qs Microsoft /proc/version_signature; then
	cd ~
	sudo sh -c "mkdir -p /run/user/$(id -u) && chown $(id -u):$(id -g) /run/user/$(id -u)"
	export SHELL=$(getent passwd $LOGNAME | cut -d: -f7)
	exec "$SHELL" -li
fi
