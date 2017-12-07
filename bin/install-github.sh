#!/bin/bash
set -eu

if [ $# -gt 1 ]; then
	for package in "$@"; do
		"$0" $package
	done
	exit
fi

SLUG="$1"
BRANCH=master
if [[ "$SLUG" = *@* ]]; then
	BRANCH=$(echo "$SLUG" | cut -d @ -f 2-)
	SLUG=$(echo "$SLUG" | cut -d @ -f 1)
fi

URL="https://github.com/$SLUG/archive/$BRANCH.tar.gz"
DIR=$(mktemp -d)

echo "$URL"
exit 1

cleanup() {
	cd /
	rm -rf "$DIR"
}

trap cleanup EXIT

cd "$DIR"
curl -L "$URL" | tar xz --strip-components=1
yes | env EUID=1 makepkg -si
