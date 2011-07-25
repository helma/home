source $HOME/.aliasrc
#source $HOME/.opentox-ui.sh

if [ `hostname` = 'zx81' ]; then
  PROMPT="%F{green}%~%f%# "
else
  PROMPT="%F{red}%~%#%f "
fi
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
zstyle ':completion:descriptions' format '%B%d%b'
zstyle ':completion:messages' format '%d'
zstyle ':completion:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''

unsetopt COMPLETE_ALIASES

setopt autocd
setopt autopushd pushdignoredups
unsetopt check_jobs
unsetopt hup

HISTFILE=$HOME/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt append_history
setopt share_history
setopt histignorealldups
setopt hist_verify
bindkey -M viins '^r' history-incremental-search-backward
bindkey -M vicmd '^r' history-incremental-search-backward

setopt extendedglob
setopt nobeep
setopt correct

hash -d ot=~/opentox-ruby/www/opentox

# define profiles based on directories:
zstyle ':chpwd:profiles:/home/ch/opentox-ruby(|/|/*)' profile opentox

# configuration for profile 'opentox':
#chpwd_profile_opentox() { source $HOME/.opentox-ui.sh }
chpwd_profile_opentox() {
  [[ ${profile} == ${CHPWD_PROFILE} ]] && return 1
    print "chpwd(): Switching to profile: $profile"
  }
