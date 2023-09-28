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

## Use the up and down arrow keys for finding a command in history
## (you can write some initial letters of the command first).
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

export PATH="$HOME/.local/bin:$PATH"

export EDITOR="helix"

export HISTFILESIZE=
export HISTSIZE=

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -f "$FNM_PATH" ]; then
    export PATH="$FNM_PATH:$PATH"
    eval "`fnm env`"
fi

. "$HOME/.cargo/env"

if command -v starship > /dev/null; then
    eval "$(starship init bash)"
fi

if [ -f ~/.bash_exec ]; then
    source ~/.bash_exec
fi
