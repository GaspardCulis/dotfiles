export PATH="$HOME/.local/bin:$PATH"

# Start DE if on tty1
if [ "$(tty)" = /dev/tty1 ]; then
	exec Hyprland
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
