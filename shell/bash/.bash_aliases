alias ls='ls --color=auto'

alias jaaj="jaaj | lolcat"
alias uwu="uwu | lolcat"
alias esp-idf-setup=". ~/.local/lib/esp-idf/export.sh"

alias steam="steam-runtime"

# Git
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull"

# Generic stuff
alias ls="ls --color=auto"
alias ip="ip --color=auto"

# uutils-coreutils aliases
if command -v pacman &> /dev/null; then
if pacman -Qi uutils-coreutils &> /dev/null; then
  for i in $(pacman -Ql uutils-coreutils | cut -d \  -f 2- | grep -E '^/usr/bin/.+' | awk -F / '{ print $4 }' | sed 's/^uu-//' | grep -v '^\[$' | xargs); do
      alias "${i}=uu-${i}"
  done
  alias ls="uu-ls --color=auto"
fi
fi
