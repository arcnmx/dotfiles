#!/bin/bash
set -eu

if [[ "$#" -lt 2 ]]; then
	echo "Usage: $0 PUBKEY_PATH GITHUB_USERNAME [GITHUB_PASSWORD]" >&2
	exit 1
fi

if [[ ! -t 0 ]]; then
	exec < /dev/tty
fi

KEYFILE="$1"
USERNAME="$2"

if [[ "$#" -lt 3 ]]; then
	PASSWORD=$(pass "$USERNAME/github.com" 2> /dev/null || true)

	if [[ -z "$PASSWORD" ]]; then
		echo -n "Enter github password for $USERNAME: " >&2
		read -rs PASSWORD
		echo >&2

		if [[ -z "$PASSWORD" ]]; then
			exit 1
		fi

		ARGS=(-u "$USERNAME:$PASSWORD")
	else
		ARGS=(-u "$USERNAME:$(echo "$PASSWORD" | head -n 1)")
		if echo "$PASSWORD" | grep -q ^otpauth://; then
			ARGS+=(-H "X-GitHub-OTP: $(pass otp "$USERNAME/github.com")")
		fi
	fi
else
	ARGS=(-u "$USERNAME:$3")
fi

KEYDATA=$(cat "$KEYFILE")
KEYCOMMENT=$(echo "$KEYDATA" | cut -d ' ' -f 3-)

POST_DATA=$(printf '{ "title": "%s", "key": "%s" }' "$KEYCOMMENT" "$KEYDATA")

curl -sSf "${ARGS[@]}" -d "$POST_DATA" "https://api.github.com/user/keys" > /dev/null
