#!/bin/bash
set -eu

if [ "$#" -lt 2 ]; then
	echo "Usage: $0 PUBKEY_PATH GITHUB_USERNAME [GITHUB_PASSWORD]" >&2
	exit 1
fi

KEYFILE="$1"
USERNAME="$2"

if [ "$#" -lt 3 ]; then
	echo -n "Enter github password for $USERNAME: " >&2
	read -rs PASSWORD
	echo >&2
else
	PASSWORD="$3"
fi

KEYDATA=$(cat "$KEYFILE")
KEYCOMMENT=$(echo "$KEYDATA" | cut -d ' ' -f 3-)

POST_DATA=$(printf '{ "title": "%s", "key": "%s" }' "$KEYCOMMENT" "$KEYDATA")

curl -sSf -u "$USERNAME":"$PASSWORD" -d "$POST_DATA" "https://api.github.com/user/keys" > /dev/null
