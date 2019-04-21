# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# | |             | |          | (_)                        #
# | |__   __ _ ___| |__    __ _| |_  __ _ ___  ___  ___     #
# | '_ \ / _` / __| '_ \  / _` | | |/ _` / __|/ _ \/ __|    #
# | |_) | (_| \__ \ | | || (_| | | | (_| \__ \  __/\__ \    #
# |_.__/ \__,_|___/_| |_| \__,_|_|_|\__,_|___/\___||___/    #
#                     ______                                #
#                    |______|                               #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

alias ls='ls --color -hN --group-directories-first'
alias l='ls'
alias l1='ls -1'
alias lf='ls | grep'
alias llf='ls -l | grep'
alias ll='ls -l'
alias la='ls -AF'
alias laf='ls -A | grep'
alias la1='ls -A1'
alias lla='la -l'
alias li='ls -i'
alias hf='history | grep'
alias h='history'
alias fstat='stat --format "%a"'
alias pf='ps aux | grep'
alias lsize='du -sh * | sort -hr'
alias showkernels='dpkg --list | grep linux-image'
alias sb='echo "Sourcing ~/.bashrc ..." && source ~/.bashrc'

# This is for neofetch
alias neo='neofetch'

# This is to check bootup services
alias blame='systemd-analyze blame'
alias blameh='systemd-analyze blame | head'
alias blamecritical='systemd-analyze critical-chain'

# This is for xclip to properly copy to clipboard
alias xclip='xclip -selection clipboard'

# This is to prompt before every removal with 'rm'
alias rm='rm -i'

# This is to log out
alias logout='gnome-session-quit'

# These are for cmake, in order to build and clean the produced files
alias cbuild='cmake -H. -Bbuild && make -C build'
alias cclean='[ -d build ] && make clean -C build && rm -rI build'

# This is to change launcher position @ Ubuntu 16.04
alias lpos='gsettings set com.canonical.Unity.Launcher launcher-position'

# This provides nvim with the argument '-p' that opens multiple file in seperate tabs
alias vim='nvim -p'
alias vi='nvim -p'
alias nvi='nvim -p'
alias nvim='nvim -p'
alias nv='nvim ~/.vimrc'
alias vv='nvim ~/.vimrc'
