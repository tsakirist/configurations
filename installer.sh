#!/usr/bin/env bash

# This script provides an easy way to install my preferred packages along with my configurations.
# Author: Tsakiris Tryfon

# --------------------------------------------- Whiptail size variables ------------------------------------------------

SIZE=$(stty size)
ROWS=$(stty size | cut -d ' ' -f 1)

# -------------------------------------------------- Font commands -----------------------------------------------------

bold=$(tput bold)
start_underline=$(tput smul)
end_underline=$(tput rmul)
black=$(tput setaf 0)
red=$(tput setaf 1)
reset=$(tput sgr0)

# ---------------------------------------------------- Symbols ---------------------------------------------------------

thunder="\u2301"
bullet="\u2022"

# ---------------------------------------------------- Functions -------------------------------------------------------

function _backup() {
    echo "Backing up $1 ..."
    cp $1 $1 -v --force --backup=numbered
}

function _reboot() {
    echo "It is recommended to ${bold}${red}reboot${reset} after a fresh install of the packages and configurations."
    read -n 1 -r -p "Would you like to reboot? [Y/n] " input
    if [[ $input =~ ^([yY]) ]]; then
        sudo reboot
    fi
}

function _prompt() {
    local exec=false
    echo -e "${bullet} Do you want to download/install ${bold}${red}${1}${reset} [Y/n] "
    read -n 1 -s input
    if [[ $input =~ ^([yY]) ]]; then
        exec=true
    fi
    if [[ $exec == "true" ]]; then
        $1
    fi
}

function _checkfile() {
    if [ ! -f "$1" ]; then
        echo "${bold}${red}ERROR${reset}: Can't find ${1} in this directory."
        echo "You should run the installer from within the github repository."
             "git clone https://github.com/tsakirist/configurations.git"
        exit 1
    fi
}

function _checkcommand() {
    if ! command -v $1 > /dev/null 2>&1; then
        echo -e "${thunder} Installing required package ${bold}${red}${1}${reset} ..."
        sudo pacman -S --needed --noconfirm $1
    fi
}

function _print() {
    local action
    if [[ $# -gt 1 ]]; then
        case "$1" in
            "s" ) action="Setting" ;;
            "i" ) action="Installing" ;;
            "c" ) action="Changing" ;;
        esac
        echo -e "${thunder} ${action} ${bold}${red}${*:2}${reset} ..."
    fi
}

# Required to build packages from AUR
function _basedevel() {
    sudo pacman -S --needed --noconfirm base-devel > /dev/null 2>&1
}

# Aur/Pacman wrapper
function _yay() {
    _print i "yay"
    sudo pacman -S --needed --noconfirm yay
}


function _change_shell() {
    local shell
    if [[ $# -eq 1 ]]; then
        case "$1" in
            "bash") shell="bash" ;;
            "zsh" ) shell="zsh" ;;
        esac
    fi
    _print c shell to $(which ${shell})
    # Issue the command to change the default shell
    chsh -s $(which ${shell})
    echo "In order for the ${start_underline}change${end_underline} to take effect you need to" \
         "${bold}${red}logout${reset}."
}

function _gitconfig() {
    _checkfile gitconfig
    _print s ".gitconfig"
    cp -v --backup=numbered gitconfig ~/.gitconfig
}

function _gitsofancy() {
    if ! command -v diff-so-fancy > /dev/null 2>&1; then
        _print s "git-diff-so-fancy"
        wget -q "https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy"
        chmod +x diff-so-fancy && sudo mv diff-so-fancy /usr/bin/
    fi
}

function _bashrc() {
    _checkfile bashrc
    _print s ".bashrc"
    cp -v --backup=numbered bashrc ~/.bashrc
}

function _bashaliases() {
    _checkfile bash_aliases
    _print s ".bash_aliases"
    cp -v --backup=numbered bash_aliases ~/.bash_aliases
}

function _bashfunctions() {
    _checkfile bash_functions
    _print s ".bash_functions"
    cp -v --backup=numbered bash_functions ~/.bash_functions
}

function _bashconfig() {
    _bashrc && _bashaliases && _bashfunctions
}

function _zsh() {
    _print i "zsh"
    sudo pacman -S --needed --noconfirm zsh
    local msg="Would you like to change the default shell to zsh?\nThis will issue 'chsh -s $(which zsh)' command."
    if (whiptail --title "Change shell" --yesno "${msg}" 8 78); then
        chsh -s $(which zsh)
    fi
}

function _zshrc() {
    _checkfile zshrc
    _print s ".zshrc"
    cp -v --backup=numbered zshrc ~/.zshrc
}

function _zshaliases() {
    _checkfile zsh_aliases
    _print s ".zsh_aliases"
    cp -v --backup=numbered zsh_aliases ~/.zsh_aliases
}

function _zshfunctions () {
    _checkfile zsh_functions
    _print s ".zsh_functions"
    cp -v --backup=numbered zsh_functions ~/.zsh_functions
}

function _zshconfig() {
    _zshrc && _zshaliases && _zshfunctions
}

function _omz() {
    local zsh_custom=${HOME}/.oh-my-zsh/custom
    _print i "oh-my-zsh"
    # Install Oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    # Install powerlevel10k theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $zsh_custom/themes/powerlevel10k
    # Install zsh autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions $zsh_custom/plugins/zsh-autosuggestions
    # Install zsh syntax highlighting and apply a specific theme
    git clone https://github.com/zdharma/fast-syntax-highlighting.git $zsh_custom/plugins/fast-syntax-highlighting
    _zshrc
}

function _vim() {
    _print i "vim"
    sudo pacman -S --needed --noconfirm vim
}

function _vimrc() {
    _checkfile vimrc
    _print s ".vimrc"
    cp -v --backup=numbered vimrc ~/.vimrc
    vim +PlugInstall +qall
}

function _nvim() {
    _print i "neovim"
    sudo pacman -S --needed --noconfirm neovim
}

function _nvimrc() {
    _checkfile vimrc && _checkfile init.vim
    _print s ".vimrc and init.vim"
    cp -v --backup=numbered vimrc ~/.vimrc
    mkdir -v -p ~/.config/nvim/
    cp -v --backup=numbered init.vim ~/.config/nvim/
    nvim +PlugInstall +qall
}

function _tmux() {
    _print i "tmux"
    sudo pacman -S --needed --noconfirm tmux
}

function _tmuxconfig() {
    _checkfile tmux.conf
    _print s ".tmux.conf"
    cp -v --backup=numbered tmux.conf ~/.tmux.conf
}

function _sublimetext() {
    _print i "SublimeText 3"
    curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg \
    && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
    if ! grep -q "[sublime-text]" /etc/pacman.conf; then
        echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" \
        | sudo tee -a /etc/pacman.conf
    fi
    sudo pacman -Syu sublime-text
}

function _sublimesettings() {
    _checkfile sublime/Preferences.sublime-settings
    _print s "sublime settings"
    cp -v --backup=numbered "sublime/Preferences.sublime-settings" "$HOME/.config/sublime-text-3/Packages/User/"
}

function _sublimekeybindings() {
    _checkfile "sublime/Default (Linux).sublime-keymap"
    _print s "sublime keybindings"
    cp -v --backup=numbered "sublime/Default (Linux).sublime-keymap" "$HOME/.config/sublime-text-3/Packages/User/"
}

function _sublimepackages() {
    _checkfile "sublime/Package Control.sublime-settings"
    _print s "sublime packages"
    cp -v --backup=numbered "sublime/Package Control.sublime-settings" "$HOME/.config/sublime-text-3/Packages/User/"
}

function _sublimeterminus() {
    _checkfile "sublime/Terminus.sublime-settings"
    _print s "sublime terminus settings"
    cp -v --backup=numbered "sublime/Terminus.sublime-settings" "$HOME/.config/sublime-text-3/Packages/User/"
}

function _sublimeconfig() {
    _sublimesettings && _sublimekeybindings && _sublimepackages && _sublimeterminus
}

function _vscode() {
    _print i "Visual Studio Code"
    _checkcommand yay &&_basedevel
    yay -S --noconfirm --needed visual-studio-code-bin 
}

function _googlechrome() {
    _print i "Google Chrome"
    _checkcommand yay && _basedevel
    yay -S --needed --noconfirm google-chrome
}

function _neofetch() {
    _print i "neofetch"
    sudo pacman -S --needed --noconfirm neofetch
}

function _xclip() {
    _print i "xclip"
    sudo pacman -S --needed --noconfirm xclip
}

function _powerline() {
    _print i "powerline"
    # sudo pacman -S --needed --noconfirm python-pip
    # pip install powerline-status
    # pip install powerline-gitstatus
    sudo pacman -S --needed --noconfirm powerline
    sudo pacman -S --needed --noconfirm powerline-fonts
}

function _powerlineconfig() {
    _checkfile powerline_configs/themes/shell/default.json && _checkfile powerline_configs/colorschemes/default.json

    _print s "themes/shell/default.json"
    cp -v --backup=numbered "powerline_configs/themes/shell/default.json" \
        "$HOME/.local/lib/python2.7/site-packages/powerline/config_files/themes/shell"

    _print s "colorschemes/default.json"
    cp -v --backup=numbered "powerline_configs/colorschemes/default.json" \
        "$HOME/.local/lib/python2.7/site-packages/powerline/config_files/colorschemes"
}

function _dconftilix() {
    _checkfile dconf/tilix.dconf
    _print s "tilix dconf settings"
    dconf load /com/gexperts/Tilix/ < dconf/tilix.dconf
}

function _dconfsettings() {
    _checkfile dconf/settings.dconf
    _print s "dconf_settings"
    dconf load / < dconf/settings.dconf
}

function _dconf() {
    _dconfsettings && _dconftilix
}

function _preload() {
    _print i "preload"
    sudo pacman -S --needed --noconfirm preload
}

function _vmswappiness() {
    _print c "vm.swappiness to 10"
    local file="/etc/sysctl.d/100-vm-swappiness.conf"
    if [ ! -f $file ]; then
        echo "vm.swappiness=10" | sudo tee $file
        sudo sysctl --system
    fi
    echo "Current swappiness value:" $(cat /proc/sys/vm/swappiness)
}

function _cmake() {
    _print i "cmake"
    sudo pacman -S --needed --noconfirm cmake
}

function _tree() {
    _print i "tree"
    sudo pacman -S --needed --noconfirm tree
}

function _htop() {
    _print i "htop"
    sudo pacman -S --needed --noconfirm htop
}

function _gnometweaks() {
    _print i "gnome-tweaks"
    sudo pacman -S --needed --noconfirm gnome-tweaks
}

function _gnomeshellextensions() {
    print i "gnome-shell-extensions"
    # Future additions of extensions should be added here
}

function _java() {
    _print i "java and javac"
    sudo pacman -S --needed --noconfirm jdk-openjdk jre-openjdk

}

function _tilix() {
    _print i "tilix: a terminal emulator"
    sudo pacman -S --needed --noconfirm tilix
}

function _setwlp() {
    local path="wallpapers/1.jpg"
    _checkfile $path
    local file="'file://$(readlink -e "${path}")'"
    _print s "Wallpaper ${FILE}"
    gsettings set org.gnome.desktop.background picture-uri "$file"
}

function _installfonts() {
    _print i "fonts"
    sudo pacman -S --needed --noconfirm otf-fira-code
}

function _fzfconfig() {
    _checkfile fzf.config
    _print s "fzf configuration"
    cp -v --backup=numbered fzf.config ~/.fzf.config
}

function _fzf() {
    _print i "fzf: Fuzzy finder"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --key-bindings --completion --no-update-rc
}

function _fd() {
    _print i "fd: an improved version of find"
    sudo pacman -S --needed --noconfirm fd
}

function _bat() {
    _print i "bat: a clone of cat with syntax highlighting"
    sudo pacman -S --needed --noconfirm bat
}

function _rg() {
    _print i "rg: ripgrep recursive search for a pattern in files"
    sudo pacman -S --needed --noconfirm ripgrep
}

function _checkroot() {
    local msg="$(printf '%s\n' \
               "Would you like to have a completely unattended installation?"  \
               "This will execute the installer with sudo to elevate privileges.")"
    if [ "$EUID" -ne 0 ]; then
        if (whiptail --title "Installer Privileges" --yesno "$msg" 8 78); then
            echo -e "${thunder} Trying to get ${start_underline}${bold}${red}root${reset} access rights... "
            sudo "$0" "$@"
            exit $?
        fi
    fi
}

function _showmenu() {
    _checkcommand whiptail
    local is_root="no"
    if [ "$EUID" -eq 0 ]; then
        is_root="yes"
    fi
    INPUT=$(whiptail --title "This script provides an easy way to install my packages and my configurations." \
        --menu "\nScript is executed from $(pwd)" ${SIZE} $((ROWS-10)) \
        "1"  "    Fresh installation" \
        "2"  "    Selective installation" \
        "Q"  "    Quit" \
        3>&1 1>&2 2>&3)
}

# ----------------------------------------------------- Installers -----------------------------------------------------

function _fresh_install() {
    _checkcommand curl && _checkcommand git
    _basedevel
    _dconf
    _installfonts
    _zsh && _zshconfig && _omz
    _bashconfig
    _tilix
    _fzf && _fzfconfig
    _fd
    _bat
    _rg
    _nvim && _nvimrc
    _tmux && _tmuxconfig
    _xclip
    _neofetch
    _htop
    _cmake
    _tree
    _gnometweaks
    _gnomeshellextensions
    _gitconfig && _gitsofancy
    _powerline && _powerlineconfig
    _java
    _sublimetext && _sublimeconfig
    _vscode
    _googlechrome
    _preload
    _vmswappiness
    _reboot
}

function _dconfgui() {
    local opt=$(whiptail --title "dconf settings" --menu "\nWhich dconf settings would you like to apply?" \
                ${SIZE} $((ROWS-10)) \
                "1" "    dconf general settings" \
                "2" "    dconf tilix settings" \
                3>&1 1>&2 2>&3)
    case $opt in
        1) _dconfsettings ;;
        2) _dconftilix ;;
    esac
}

function _guimenu() {
    OPT=$(whiptail --title "Selectively install packages/configurations" \
        --menu "\nSelect the packages and the configurations that you want to install/set." ${SIZE} $((ROWS-10)) \
        "1"  "    dconf settings" \
        "2"  "    zsh" \
        "3"  "    zshrc, zsh_aliases, zsh_functions" \
        "4"  "    oh-my-zsh" \
        "5"  "    bashrc, bash_aliases, bash_functions" \
        "6"  "    tilix: terminal emulator" \
        "7"  "    fzf: fuzzy finder" \
        "8"  "    fzf configuration" \
        "9"  "    fd: improved version of find" \
        "10" "    bat: a cat clone with syntax highlighting" \
        "11" "    rg: ripgrep recursive search for a pattern in files" \
        "12" "    neovim" \
        "13" "    neovimrc" \
        "14" "    tmux: terminal multiplexer" \
        "15" "    tmux configuration" \
        "16" "    xclip" \
        "17" "    neofetch" \
        "18" "    htop" \
        "19" "    cmake" \
        "20" "    tree" \
        "21" "    gnome-tweaks" \
        "22" "    gnome-shell-extensions" \
        "23" "    gitconfig" \
        "24" "    gitsofancy" \
        "25" "    powerline" \
        "26" "    powerline configuration" \
        "27" "    java & javac" \
        "28" "    sublime text 3" \
        "29" "    sublime text 3: settings, keybindings, packages" \
        "30" "    vscode" \
        "31" "    google chrome" \
        "32" "    preload" \
        "33" "    vmswappiness" \
        "34" "    set wallpaper" \
        "35" "    install fonts" \
        "Q"  "    Quit" \
        3>&1 1>&2 2>&3)
}

function _selective_install() {
    _checkcommand curl && _checkcommand git
    local exit_status=0
    while [[ $exit_status -eq 0 ]]; do
        _guimenu
        case $OPT in
            1 ) _dconfgui ;;
            2 ) _zsh ;;
            3 ) _zshconfig ;;
            4 ) _omz ;;
            5 ) _bashconfig ;;
            6 ) _tilix ;;
            7 ) _fzf ;;
            8 ) _fzfconfig ;;
            9 ) _fd ;;
            10) _bat ;;
            11) _rg ;;
            12) _nvim ;;
            13) _nvimrc ;;
            14) _tmux ;;
            15) _tmuxconfig ;;
            16) _xclip ;;
            17) _neofetch ;;
            18) _htop ;;
            19) _cmake ;;
            20) _tree ;;
            21) _gnometweaks ;;
            22) _gnomeshellextensions ;;
            23) _gitconfig ;;
            24) _gitsofancy ;;
            25) _powerline ;;
            26) _powerlineconfig ;;
            27) _java ;;
            28) _sublimetext ;;
            29) _sublimeconfig ;;
            30) _vscode ;;
            31) _googlechrome ;;
            32) _preload ;;
            33) _vmswappiness ;;
            34) _setwlp ;;
            35) _installfonts ;;
            Q | *) exit_status=1 ;;
        esac
        # Sleep only when user hasn't selected Quit
        [ $exit_status -eq 0 ] && sleep 2
    done
}

# ------------------------------------------------------- Main ---------------------------------------------------------
# _checkroot

_showmenu

if [[ $INPUT -eq 1 ]]; then
    _fresh_install
elif [[ $INPUT -eq 2 ]]; then
    _selective_install
else
    exit 0
fi
