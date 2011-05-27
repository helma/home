source $HOME/.aliasrc
source $HOME/.opentox-ui.sh

PROMPT="%F{green}%~%f%# "
RPROMPT="%F{blue}%n%f@%F{red}%m%f"
if [[ -o login ]]; then
else
  echo -ne "\033]12;red\007" # set prompt
fi

bindkey -v

fpath=($fpath /usr/share/doc/task/scripts/zsh $HOME/.zsh)
autoload -Uz compinit
compinit
zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-colors ''
unsetopt COMPLETE_ALIASES

setopt autocd
setopt autopushd pushdignoredups
unsetopt check_jobs
unsetopt hup

HISTFILE=$HOME/.zsh_history
HISTSIZE=5000
SAVEHIST=10000
setopt append_history
setopt share_history
setopt histignorealldups
setopt hist_verify
bindkey -M viins '^r' history-incremental-search-backward
bindkey -M vicmd '^r' history-incremental-search-backward

setopt extendedglob

hash -d ot=~/opentox-ruby/www/opentox

