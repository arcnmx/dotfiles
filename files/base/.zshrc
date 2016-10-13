PROMPT_EOL_MARK=
KEYTIMEOUT=1
REPORTTIME=30
DEFAULT_USER=arc

. ~/.bashrc.env

setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

setopt rmstarsilent
setopt nonomatch
setopt long_list_jobs
setopt interactivecomments

setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt nosharehistory
alias history='fc -il 1'
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

autoload -U compinit
compinit -u -i

WORDCHARS=''
zmodload -i zsh/complist
unsetopt menu_complete
setopt auto_menu
setopt no_auto_remove_slash
setopt complete_in_word
setopt always_to_end
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

. ~/.zshrc.title
. ~/.zshrc.prompt
. ~/.zshrc.vimode
. ~/.bashrc.alias

if [[ -o login ]]; then
	. ~/.bashrc.login
fi
