PROMPT_EOL_MARK=
KEYTIMEOUT=1
REPORTTIME=30

. ~/.bashrc.env
. ~/.zshenv.omz
. ~/.bashrc.alias

setopt rmstarsilent
setopt nosharehistory
setopt nonomatch

if [ -n "$ARC_OSX" ]; then
	# skip running OS X path_helper
	_arc_osx_debug() {
		if [[ "$ZSH_DEBUG_CMD" = */usr/libexec/path_helper* ]]; then
			set -e 0
		fi
	}
	trap _arc_osx_debug DEBUG
fi
