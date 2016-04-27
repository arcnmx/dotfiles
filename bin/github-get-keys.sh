#!/bin/bash
set -eu

if [ "$#" -lt 1 ]; then
	echo "Usage: $0 GITHUB_USERNAME [GITHUB_PASSWORD]" >&2
	exit 1
fi

USERNAME="$1"

if [ "$#" -lt 2 ]; then
	echo -n "Enter github password for $USERNAME: " >&2
	stty -echo > /dev/null 2>&1 || true
	read -r PASSWORD
	stty echo > /dev/null 2>&1 || true
	echo >&2
else
	PASSWORD="$2"
fi

curl -sSf -u "$USERNAME":"$PASSWORD" "https://api.github.com/user/keys" | grep '"key"' | grep -o 'ssh-[^"]*'
