#!/bin/bash
set -eu

WINDOWS=/mnt/c/Windows
PATH="$PATH:$WINDOWS:$WINDOWS/System32:$WINDOWS/System32/WindowsPowerShell/v1.0"

windowsenv() {
	(cd "$WINDOWS" && powershell.exe -Command "(resolve-path -Path \$env:$1).Path") | tr -d '\r'
}

cmd_update() {
	TMPDIR=$(windowsenv TEMP | winpath)
	HOMEPATH=$(windowsenv HOMEPATH | winpath)

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
	icacls.exe "$(windowsenv HOMEPATH)/.ssh" /grant "NT Service\\sshd:R" /T
	powershell.exe -Command 'New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH'
	# Take control of (right-click, permissions, advanced, owner, change. then give full control):
	# HKEY_LOCAL_MACHINE\SOFTWARE\Classes\AppID{F72671A9-012C-4725-9D2F-2A4D32D65169}
	# HKEY_CLASSES_ROOT\CLSID\{4f476546-b412-4579-b64c-123df331e3d6}
	# Then adjust permissions in DCOM Component Services for AppId F72671A9-012C-4725-9D2F-2A4D32D65169 - otherwise error 0x80070005 will occur when running bash.exe
}

COMMAND=$1
shift

cmd_$COMMAND "$@"
