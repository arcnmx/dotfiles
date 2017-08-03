#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)
set -e

xrdb -merge -I$HOME ~/.Xresources

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

# Reverses scroll direction
#xmodmap ~/.xmodmap

#wallpaper

HOSTNAME=$(hostname)
if [[ "$HOSTNAME" = "satorin" ]]; then
	sxhkd & > /dev/null 2>&1
	syndaemon -K -d -m 100 -i 0.1
fi

if [[ "$HOSTNAME" = "shanghai" ]]; then
	compton -bGC --no-fading-openclose
else
	xcompmgr &
fi

urxvtd &

#dropboxd &

exec awesome
