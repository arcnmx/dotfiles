PROMPT_EOL_MARK=
KEYTIMEOUT=1
REPORTTIME=30

. ~/.bashrc.env
. ~/.zshrc.omz
. ~/.bashrc.alias

setopt rmstarsilent
setopt nosharehistory
setopt nonomatch

if [[ -o login ]]; then
	. ~/.bashrc.login
fi
