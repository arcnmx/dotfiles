#!/bin/sh
set -eu

# Remote usage:
# bash -c "$(curl -sSfL https://raw.githubusercontent.com/arcnmx/dotfiles/master/bin/download.sh)" dotfiles [ARGS]

GIT_URL="https://github.com/arcnmx/dotfiles.git"

OPT_ROOT=
OPT_SETUP_TYPE=

print_usage() {
	echo "Usage: $0 [-r] [-s SETUP_TYPE]" >&2
	echo "    -h: print this help" >&2
	echo "    -r: install in /.dotfiles as root" >&2
	echo "    -s SETUP_TYPE: initiate system setup as the specified system TYPE" >&2
	exit 1
}

while getopts ":hrs:" opt; do
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
		\?)
			echo "Invalid option -$OPTARG" >&2
			print_usage
			;;
		:)
			echo "Option -$OPTARG requires an argument" >&2
			print_usage
			;;
	esac
done
shift $((OPTIND-1))

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
./dot.sh crypt-unlock
git remote set-url --push origin git@github.com:arcnmx/dotfiles.git
if [ -n "$OPT_SETUP_TYPE" ]; then
	./dot.sh setup "$OPT_SETUP_TYPE"
	./dot.sh update-system
	./dot.sh crypt-unlock # we maybe just installed a system-wide git-crypt
fi
./dot.sh update
