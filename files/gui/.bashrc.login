if [[ -z "${TMUX-}" && -z "${DISPLAY-}" && "${XDG_VTNR-}" = 1 && $(id -u) != 0 ]] && which startx > /dev/null 2>&1; then
	startx
fi
