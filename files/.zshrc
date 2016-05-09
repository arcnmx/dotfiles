PROMPT_EOL_MARK=
KEYTIMEOUT=1
REPORTTIME=30

. ~/.bashrc.env

# Hack around homebrew's poor zsh install permissions
if [ -n "$ARC_OSX" ]; then
	ZSH_DISABLE_COMPFIX=false
	compaudit() {
		true
	}
	alias compinit='compinit -u'
fi

. ~/.zshrc.omz
. ~/.bashrc.alias

setopt rmstarsilent
setopt nosharehistory
setopt nonomatch

if [[ -o login ]]; then
	. ~/.bashrc.login
fi
