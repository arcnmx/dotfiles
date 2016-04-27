[[ $- != *i* ]] && return

if [[ -z "${ARC_ENV-}" ]]; then
	. ~/.bashrc.env
fi

. ~/.bashrc.int
. ~/.bashrc.alias
