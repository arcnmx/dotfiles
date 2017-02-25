if [[ -z "$DISPLAY" && "$XDG_VTNR" -eq 1 ]] && [ $(id -u) != 0 ] && which startx > /dev/null 2>&1; then
	startx
fi
