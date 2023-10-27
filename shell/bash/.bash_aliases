alias ls='ls --color=auto'

alias jaaj="jaaj | lolcat"
alias esp-idf-setup=". ~/.local/lib/esp-idf/export.sh"

alias steam="steam-runtime"

# Git
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull"

# Obsidian
alias life-push="rsync -r ~/Documents/Obsidian/Life/ pixel:~/storage/shared/Documents/Obsidian/Life/"
alias life-pull="rsync -r pixel:~/storage/shared/Documents/Obsidian/Life/ ~/Documents/Obsidian/Life/"

# Config
alias editconf-i3="hx ~/.config/i3"

# Generic stuff
alias ls="ls --color=auto"
alias ip="ip --color=auto"

# uutils-coreutils aliases
if command -v pacman &> /dev/null; then
if pacman -Qi uutils-coreutils &> /dev/null; then
  for b in $(pacman -Ql uutils-coreutils | grep bin | cut -d ' ' -f 2 | cut -d '/' -f 4 | cut -d '-' -f 2); do
    alias $b="uu-$b"
  done
  unalias [
  alias ls="uu-ls --color=auto"
fi
fi

