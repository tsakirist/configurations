# # # # # # # # # # # # # # # # # # #
#  _               _                #
# | |__   __ _ ___| |__  _ __ ___   #
# | '_ \ / _` / __| '_ \| '__/ __|  #
# | |_) | (_| \__ \ | | | | | (__   #
# |_.__/ \__,_|___/_| |_|_|  \___|  #
#                                   #
# # # # # # # # # # # # # # # # # # #

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
# HISTSIZE=1000
# HISTFILESIZE=2000
HISTSIZE=
HISTFILESIZE=
HISTTIMEFORMAT="%d/%m/%Y %H:%M:%S:   "

# Disable CTRL-s and CTRL-q
[[ $- =~ i ]] && stty -ixoff -ixon

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
            "$(history|tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# This is required for powerline to be enabled
if [ -f `which powerline-daemon` ]; then
    powerline-daemon -q
    POWERLINE_BASH_CONTINUATION=1
    POWERLINE_BASH_SELECT=1
    . "$HOME/.local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh"
fi

# Add this to automatically start tmux with new shell
if [ -z "$TMUX" ]; then
    tmux attach 2> /dev/null || tmux new-session
fi

# This command allows to enter a directory by merely typing the directory name w/o 'cd'
shopt -s autocd

# Make neovim default editor
export VISUAL=nvim
export EDITOR="$VISUAL"

# Source my custom functions
[ -f ~/.bash_functions ] && . ~/.bash_functions

# Source fzf, to be able to use it
[ -f ~/.bash.zsh ] && . ~/.bash.zsh

# Source my fzf configurations
[ -f ~/.fzf.config ] && . ~/.fzf.config
