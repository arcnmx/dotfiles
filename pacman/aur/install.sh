#!/bin/bash
set -eu

if [ $# -gt 1 ]; then
	for package in "$@"; do
		"$0" $package
	done
	exit
fi

PACKAGE="$1"
URL="https://aur.archlinux.org/cgit/aur.git/snapshot/$PACKAGE.tar.gz"
DIR=`mktemp -d`

cleanup() {
	cd /
	rm -rf "$DIR"
}

trap cleanup EXIT

cd "$DIR"
curl -L "$URL" | tar xz --strip-components=1
env EUID=1 makepkg -si --noconfirm
