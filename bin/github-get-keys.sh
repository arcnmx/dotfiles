#!/bin/bash
set -eu

if [[ "$#" -lt 1 ]]; then
	echo "Usage: $0 GITHUB_USERNAME [GITHUB_PASSWORD]" >&2
	exit 1
fi

if [[ ! -t 0 ]]; then
	exec < /dev/tty
fi

USERNAME="$1"

if [[ "$#" -lt 2 ]]; then
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
	ARGS=(-u "$USERNAME:$2")
fi

curl -sSf "${ARGS[@]}" "https://api.github.com/user/keys" | grep '"key"' | grep -o 'ssh-[^"]*'
