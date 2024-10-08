# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PS1='\[\033[1;33m\]\u\[\033[1;37m\]@\[\033[1;32m\]\h\[\033[1;37m\]:\[\033[1;31m\]\w \[\033[1;36m\]\$ \[\033[0m\]'


[[ "$(whoami)" = "root" ]] && return

if [ -f ~/.bash_env ]; then
    source ~/.bash_env
fi

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

[[ -z "$FUNCNEST" ]] && export FUNCNEST=100          # limits recursive functions, see 'man bash'

[[ -z "$XDG_CONFIG_HOME" ]] && export XDG_CONFIG_HOME="$HOME/.config"

## Use the up and down arrow keys for finding a command in history
## (you can write some initial letters of the command first).
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

export PATH="$HOME/.local/bin:$HOME/.nix-profile/bin:$PATH"

export EDITOR="hx"

export HISTFILESIZE=
export HISTSIZE=4294967295

CARGO_ENV_PATH="$HOME/.cargo/env"
if [ -f "$CARGO_ENV_PATH" ]; then
    . "$CARGO_ENV_PATH"
fi

FLUTTER_PATH="/opt/flutter/bin"
if test -d "$FLUTTER_PATH"; then
    export PATH="$FLUTTER_PATH:$PATH"
fi

if [ -f ~/.bash_exec ]; then
    source ~/.bash_exec
fi
