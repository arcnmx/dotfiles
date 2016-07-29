#!/bin/sh
set -eu

# Remote usage:
# bash -c "$(curl -sSfL https://raw.githubusercontent.com/arcnmx/dotfiles/master/bin/download.sh)" dotfiles [ARGS]

GIT_URL="https://github.com/arcnmx/dotfiles.git"

OPT_ROOT=
OPT_SETUP_TYPE=
OPT_NO_CRYPT=

print_usage() {
	echo "Usage: $0 [-rC] [-s SETUP_TYPE]" >&2
	echo "    -h: print this help" >&2
	echo "    -r: install in /.dotfiles as root" >&2
	echo "    -s SETUP_TYPE: initiate system setup as the specified system TYPE" >&2
	echo "    -C: don't decrypt data" >&2
	exit 1
}

while getopts ":hrCs:" opt; do
	case "$opt" in
		h) # --help
			print_usage
			;;
		r) # --root
			# installs in /.dotfiles instead of $HOME/.dotfiles
			OPT_ROOT=y
			;;
		s) # --setup TYPE
			OPT_SETUP_TYPE="$OPTARG"
			;;
		C) # --no-crypt
			OPT_NO_CRYPT=y
			;;
		\?)
			echo "Invalid option -$OPTARG" >&2
			print_usage >&2
			;;
		:)
			echo "Option -$OPTARG requires an argument" >&2
			print_usage >&2
			;;
	esac
done
shift $((OPTIND-1))

crypt_unlock() {
	if [ -n "$OPT_NO_CRYPT" ]; then
		./dot.sh crypt-unlock
	fi
}

DOTFILES_PATH="$HOME/.dotfiles"

if [ ! -e "$DOTFILES_PATH" ]; then
	if [ -n "$OPT_ROOT" ]; then
		ln -sf /.dotfiles "$DOTFILES_PATH"
		DOTFILES_PATH=/.dotfiles
	fi
	mkdir -p "$DOTFILES_PATH"
	git clone "$GIT_URL" "$DOTFILES_PATH"
fi
cd "$DOTFILES_PATH"
crypt_unlock
git remote set-url --push origin git@github.com:arcnmx/dotfiles.git
if [ -n "$OPT_SETUP_TYPE" ]; then
	./dot.sh setup "$OPT_SETUP_TYPE"
	./dot.sh update-system
	crypt_unlock # we maybe just installed a system-wide git-crypt
fi
./dot.sh update
