# vim:ft=zsh ts=4 sw=4 sts=4

prompt_end() {
	local PROMPT=":;"
	if [[ "${KEYMAP-}" == "vicmd" ]]; then
		PROMPT=" :"
	fi
	echo -en "%{%f%k%}\n%{%F{white}%B%}$PROMPT%{%b%f%}"
}

PROMPT_SEGMENT=""
prompt_segment() {
	if [[ -n "$PROMPT_SEGMENT" ]]; then
		echo -n " "
	fi

	echo -n "$1"
	PROMPT_SEGMENT=x
}

# Context: user@hostname
prompt_context() {
	if [[ "$USER" != "$DEFAULT_USER" || -n "${SSH_CLIENT-}" ]]; then
		prompt_segment "%{%F{red}%}$USER%{%f%B%}@%{%b%F{red}%}%m%{%f%}"
	fi
}

# Git: branch/detached head, dirty status
prompt_git() {
	local ref dirty mode repo_path
	repo_path=$(git rev-parse --git-dir 2>/dev/null)

	if [[ -n "$repo_path" ]]; then
		dirty=$(parse_git_dirty)
		ref=$(git symbolic-ref HEAD --short 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"

		if [[ -n "$dirty" ]]; then
			dirty="yellow"
		else
			dirty="green"
		fi

		if [[ -e "${repo_path}/BISECT_LOG" ]]; then
			mode=" :: bisect"
		elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
			mode=" :: merge"
		elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" ]]; then
			mode=" :: rebase"
		fi

		prompt_segment "%{%F{$dirty}%}(git: $ref$mode)%{%f%}"
	fi
}

# Dir: current working directory
prompt_dir() {
	prompt_segment "%{%F{blue}%B%}%~%{%b%f%}"
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
	local symbols
	symbols=()
	[[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}!"
	[[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}#"
	[[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}&"

	[[ -n "$symbols" ]] && prompt_segment "$symbols%{%f%}"
}

## Main prompt
build_prompt() {
	RETVAL=$?
	prompt_status
	prompt_context
	prompt_dir
	prompt_git
	prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
#RPROMPT='$(date)'