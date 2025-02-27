alias jaaj="jaaj | dotacat"
alias uwu="uwu | dotacat"
alias esp-idf-setup=". ~/.local/lib/esp-idf/export.sh"

alias steam="steam-runtime"

# Git
alias gs="git status"
alias ga="git add -p"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull"

# Nix
alias ns="nix-shell"
alias nsp="nix-shell -p"

# uutils-coreutils aliases
if command -v pacman &> /dev/null; then
if pacman -Qi uutils-coreutils &> /dev/null; then
  for i in $(pacman -Ql uutils-coreutils | cut -d \  -f 2- | grep -E '^/usr/bin/.+' | awk -F / '{ print $4 }' | sed 's/^uu-//' | grep -v '^\[$' | xargs); do
      alias "${i}=uu-${i}"
  done
  alias ls="uu-ls --color=auto"
fi
fi

# Generic stuff
if command -v lsd &> /dev/null; then
  alias ls="lsd"
  alias l="lsd -alh"
else
  alias ls="ls --color=auto"
  alias l="ls -alh --color=auto"
fi
alias ip="ip --color=auto"
alias tld="tree -L 2"

alias mnt-s3="s3fs public ${S3_MOUNTPOINT} -o passwd_file=${HOME}/.passwd-s3fs -o host=${S3_HOST} -o endpoint=${S3_ENDPOINT}"

# Termux related
if command -v ssha &> /dev/null; then
  alias ssh="ssha"
fi
