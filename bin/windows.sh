#!/bin/bash
set -eu

WINDOWS=/mnt/c/Windows
PATH="$PATH:$WINDOWS:$WINDOWS/System32/WindowsPowerShell/v1.0"

windowsenv() {
	(cd "$WINDOWS" && powershell.exe -Command "(resolve-path -Path \$env:$1).Path") | tr -d '\r' | winpath
}

cmd_update() {
	TMPDIR=$(windowsenv TEMP)
	HOMEPATH=$(windowsenv HOMEPATH)

	WORKING=$(mktemp -d -p "$TMPDIR")

	cleanup() {
		rm -rf "$WORKING"
	}

	trap cleanup EXIT

	# Solarized cmd.exe theme
	SOLARIZED=neilpa/cmd-colors-solarized
	git clone -q https://github.com/$SOLARIZED "$WORKING/solarized"
	(cd "$WORKING" && powershell.exe -Command 'Start-Process -Wait -Verb RunAs -ArgumentList "/s","$PWD/solarized/solarized-dark.reg" regedit.exe')

	# vimperatorrc
	cp files/gui/.vimperatorrc "$HOMEPATH/"

	# ssh
	mkdir -p "$HOMEPATH/.ssh"
	cp "$HOME/.ssh/authorized_keys" "$HOMEPATH/.ssh/"
}

COMMAND=$1
shift

cmd_$COMMAND "$@"
