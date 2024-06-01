#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Start DE if on tty1
if [ "$(tty)" = /dev/tty1 ]; then
	exec Hyprland
fi
