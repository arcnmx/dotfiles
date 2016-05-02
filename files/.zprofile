. ~/.bashrc.env
. ~/.bashrc.login

if [ -n "$ARC_OSX" ]; then
	# unset path_helper inhibitor
	trap DEBUG
	PATH="$PATH$(
		setopt null_glob;
		for f in /etc/paths.d/*; do
			echo -n ":$(cat $f)" | tr '\n' ':'
		done
	)"
fi
