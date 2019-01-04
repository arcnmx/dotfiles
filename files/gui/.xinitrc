#!/bin/sh

set -e

xrdb -merge -I$HOME ~/.Xresources

#export XDG_CURRENT_DESKTOP=awesome
export XDG_CURRENT_DESKTOP=i3

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

setxkbmap -option numpad:microsoft
setxkbmap -option numpad:shift3
setxkbmap -option ctrl:nocaps
xsetroot -cursor_name left_ptr

#wallpaper

HOSTNAME=$(hostname)
if [[ "$HOSTNAME" = "satorin" ]]; then
	if [[ "$XDG_CURRENT_DESKTOP" != i3 ]]; then
		sxhkd & > /dev/null 2>&1
	fi
	syndaemon -K -d -m 100 -i 0.1
fi

#compton -bGC --no-fading-openclose
xcompmgr &

urxvtd &

#dropboxd &

xrandr > /dev/null 2>&1
randr default

exec "$XDG_CURRENT_DESKTOP"
