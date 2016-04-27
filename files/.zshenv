PROMPT_EOL_MARK=
KEYTIMEOUT=1
REPORTTIME=30

if [[ -z "${ARC_ENV-}" ]]; then
	. ~/.bashrc.env
fi

. ~/.zshenv.omz
. ~/.bashrc.alias

setopt rmstarsilent
setopt nosharehistory
setopt nonomatch
