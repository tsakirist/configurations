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
green=$(tput setaf 2)
reset=$(tput sgr0)

# ---------------------------------------------------- Symbols ---------------------------------------------------------

thunder="\u2301"
bullet="\u2022"
cross="\u2718"
tick="\u2714"
spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

# ---------------------------------------------------- Functions -------------------------------------------------------

function _spin() {
    # Make the cursor invisible for the duration
    tput civis
    # Print some whitespace before the spinner
    echo -ne "  "
    while true; do
        for i in "${spinner[@]}"; do
            echo -ne "\b$i"
            sleep .1
        done
    done
}

function _endspin() {
    local PID=$1
    local LAST_STATUS=$2
    # Disown or Wait is necessary to suppress shell's output when a background job is killed
    # disown $PID
    kill -9 $PID
    wait $PID 2> /dev/null
    [ $LAST_STATUS -eq 0 ] && echo -e "${green}\b${tick}${reset}" || echo -e "${red}\b${cross}${reset}"
    tput cnorm
}

function _aptinstall() {
    # -qq: option implies --yes and also is less verbose
    sudo apt-get -qq install "$@" > /dev/null
}

function _checkppa() {
    for i in "$@"; do
        if ! grep -Rq "^deb.*$i" /etc/apt/sources.list.d/*.list; then
            sudo add-apt-repository -y ppa:$i > /dev/null
            sudo apt-get -qq update
        fi
    done
}

function _backup() {
    echo "Backing up $1 ..."
    cp $1 $1 -v --force --backup=numbered
}

function _reboot() {
    echo "It is recommended to ${bold}${red}reboot${reset} after a fresh install of the packages and configurations."
    read -n 1 -r -p "Would you like to reboot? [Y/n] " input
    if [[ "$input" =~ ^([yY])$ ]]; then
        sudo reboot
    fi
}

function _prompt() {
    local exec=false
    echo -e "${bullet} Do you want to download/install ${bold}${red}${1}${reset} [Y/n] "
    read -n 1 -s input
    if [[ "$input" =~ ^([yY])$ ]]; then
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
        echo -ne "${thunder} Installing required package ${bold}${red}${1}${reset}..."
        _spin &
        _aptinstall $1
        _spin $! $?
    fi
}

function _print() {
    local action
    if [[ $# -gt 1 ]]; then
        case "$1" in
            "s") action="Setting" ;;
            "i") action="Installing" ;;
            "c") action="Changing" ;;
        esac
        echo -ne "${thunder} ${action} ${bold}${red}${*:2}${reset}..."
        # Insert a newline for formatting options
        [ "$1" != "i" ] && echo
    fi
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
    _checkfile git/gitconfig
    _print s ".gitconfig"
    cp -v --backup=numbered git/gitconfig ~/.gitconfig
}

function _gitsofancy() {
    if ! command -v diff-so-fancy > /dev/null 2>&1; then
        _print s "git-diff-so-fancy"
        wget -q "https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy"
        chmod +x diff-so-fancy && sudo mv diff-so-fancy /usr/bin/
    fi
}

function _bashrc() {
    _checkfile bash/bashrc
    _print s ".bashrc"
    cp -v --backup=numbered bash/bashrc ~/.bashrc
}

function _bashaliases() {
    _checkfile bash/bash_aliases
    _print s ".bash_aliases"
    cp -v --backup=numbered bash/bash_aliases ~/.bash_aliases
}

function _bashfunctions() {
    _checkfile bash/bash_functions
    _print s ".bash_functions"
    cp -v --backup=numbered bash/bash_functions ~/.bash_functions
}

function _bashconfig() {
    _bashrc && _bashaliases && _bashfunctions
}

function _zsh() {
    _print i "zsh"
    _spin &
    _aptinstall zsh
    if [ $# -eq 0 ]; then
        local msg="Would you like to change the default shell to zsh?\nThis will issue 'chsh -s $(which zsh)' command."
        if (whiptail --title "Change shell" --yesno "${msg}" 8 78); then
            chsh -s $(which zsh)
        fi
    else
        [ "$1" == "-y" ] && chsh -s $(which zsh) ||
        echo "${red}ERROR${reset}: Wrong supplied argument '$1' @_zsh:line $LINENO" && exit 1
    fi
    _endspin $! $?
}

function _zshrc() {
    _checkfile zsh/zshrc
    _print s ".zshrc"
    cp -v --backup=numbered zsh/zshrc ~/.zshrc
}

function _zshaliases() {
    _checkfile zsh/zsh_aliases
    _print s ".zsh_aliases"
    cp -v --backup=numbered zsh/zsh_aliases ~/.zsh_aliases
}

function _zshfunctions () {
    _checkfile zsh/zsh_functions
    _print s ".zsh_functions"
    cp -v --backup=numbered zsh/zsh_functions ~/.zsh_functions
}

function _zshconfig() {
    _zshrc && _zshaliases && _zshfunctions
}

function _omz() {
    local zsh_custom=${HOME}/.oh-my-zsh/custom
    _print i "oh-my-zsh"
    _spin &
    # Install Oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    # Install powerlevel10k theme
    git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git $zsh_custom/themes/powerlevel10k
    # Install zsh autosuggestions
    git clone -q https://github.com/zsh-users/zsh-autosuggestions $zsh_custom/plugins/zsh-autosuggestions
    # Install zsh syntax highlighting and apply a specific theme
    git clone -q https://github.com/zdharma/fast-syntax-highlighting.git $zsh_custom/plugins/fast-syntax-highlighting
    _endspin $! $?
    _zshrc
}

function _vim() {
    _print i "vim"
    _spin &
    _aptinstall vim vim-gnome
    _endspin $! $?
}

function _vimrc() {
    _checkfile neovim/vimrc
    _print s ".vimrc"
    cp -v --backup=numbered neovim/vimrc ~/.vimrc
    vim +PlugInstall +qall
}

function _nvim() {
    _print i "neovim"
    _spin &
    _checkppa neovim-ppa/stable
    # sudo add-apt-repository ppa:neovim-ppa/stable -y > /dev/null
    sudo apt-get -qq update && _aptinstall neovim
    _endspin $! $?
}

function _nvimrc() {
    _checkfile neovim/vimrc && _checkfile neovim/init.vim
    _print s ".vimrc and init.vim"
    cp -v --backup=numbered neovim/vimrc ~/.vimrc
    mkdir -v -p ~/.config/nvim/
    cp -v --backup=numbered neovim/init.vim ~/.config/nvim/
    nvim +PlugInstall +qall
}

function _tmux() {
    _print i "tmux"
    _spin &
    _aptinstall tmux
    _endspin $! $?
}

function _tmuxconfig() {
    _checkfile tmux/tmux.conf
    _print s ".tmux.conf"
    cp -v --backup=numbered tmux/tmux.conf ~/.tmux.conf
}

function _sublimepkgctrl() {
    # Create the necessary folder for Package Control and install it manually
    if [ ! -f "${HOME}/.config/sublime-text-3/Installed Packages/Package Control.sublime-package" ]; then
        wget -q "https://packagecontrol.io/Package%20Control.sublime-package" \
             -P "${HOME}/.config/sublime-text-3/Installed Packages"
    fi
}

function _sublimeinit() {
    # Create some necessary folders in order to be able to copy settings
    mkdir -v -p "${HOME}/.config/sublime-text-3/Installed Packages"
    mkdir -v -p "${HOME}/.config/sublime-text-3/Packages/User/"
    _sublimepkgctrl
}

function _sublimetext() {
    _print i "SublimeText 3"
    _spin &
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    sudo sh -c 'echo "deb https://download.sublimetext.com/ apt/stable/" > \
                /etc/apt/sources.list.d/sublime-text.list'
    sudo apt-get -qq update && _aptinstall sublime-text
    _endspin $! $?
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
    _spin &
    curl -s https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && rm -f microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > \
                /etc/apt/sources.list.d/vscode.list'
    sudo apt-get -qq update && _aptinstall code
    _endspin $! $?
}

function _googlechrome() {
    _print i "Google Chrome"
    _spin &
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google_chrome.deb
    sudo dpkg -i /tmp/google_chrome.deb > /dev/null
    _endspin $! $?
    # Remove google chrome keyring pop-up
    sudo sed -i '/^Exec=/s/$/ --password-store=basic %U/' "/usr/share/applications/google-chrome.desktop"
}

function _neofetch() {
    _print i "neofetch"
    _spin &
    _aptinstall neofetch
    _endspin $! $?
}

function _xclip() {
    _print i "xclip"
    _spin &
    _aptinstall xclip
    _endspin $! $?
}

function _powerline() {
    _print i "powerline"
    _spin &
    _aptinstall python-pip
    pip install -q powerline-status
    pip install -q powerline-gitstatus
    _aptinstall fonts-powerline
    _endspin $! $?
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
    _print s "dconf settings"
    dconf load / < dconf/settings.dconf
}

function _dconfsettingswthemes() {
    _checkfile dconf/settings_with_themes.dconf
    _print s "dconf settings with themes"
    dconf load / < dconf/settings_with_themes.dconf
}

# By default it includes dconf settings with themes applied
function _dconf() {
    _dconfsettingswthemes && _dconftilix
}

function _preload() {
    _print i "preload"
    _spin &
    _aptinstall preload
    _endspin $! $?
}

function _vmswappiness() {
    local value=10
    local file="/etc/sysctl.conf"
    _print c "vm.swappiness to $value"
    if grep -q "^vm.swappiness" $file; then
        sudo sed -i "s/\(^vm.swappiness=\).*/\1$value/" $file
    else
        echo "vm.swappiness=${value}" | sudo tee -a $file > /dev/null 2>&1;
    fi
    sudo sysctl -q --system
    echo "Swappiness value:" $(cat /proc/sys/vm/swappiness)
}

function _cmake() {
    _print i "cmake"
    _spin &
    _aptinstall cmake
    _endspin $! $?
}

function _tree() {
    _print i "tree"
    _spin &
    _aptinstall tree
    _endspin $! $?
}

function _htop() {
    _print i "htop"
    _spin &
    _aptinstall htop
    _endspin $! $?
}

function _gnometweaks() {
    _print i "gnome-tweaks"
    _spin &
    _aptinstall gnome-tweaks
    _endspin $! $?
}

function _arcmenu() {
    _print i "Arc-Menu extension"
    _spin &
    # Install prerequisites
    _aptinstall gnome-menus gettext libgettextpo-dev
    pushd /tmp > /dev/null
    git -q clone https://gitlab.com/LinxGem33/Arc-Menu.git
    make --quiet uninstall
    make --quiet install
    popd > /dev/null
    _endspin $! $?
}

function _gnomeshellextensions() {
    _print i "gnome-shell-extensions"
    _spin &
    # This installs a minimal set of extensions
    _aptinstall gnome-shell-extensions gnome-shell-extension-weather gnome-shell-extension-dashtodock
    _endspin $! $?
    _arcmenu
}

function _arctheme() {
    _print i "Arc-theme"
    _spin &
    _aptinstall arc-theme
    _endspin $! $?
}

function _papirusicons() {
    _print i "Papirus icons and folders script"
    _spin &
    _checkppa papirus/papirus
    _aptinstall papirus-icon-theme papirus-folders
    _endspin $! $?
    sudo papirus-folders -C deeporange
}

function _java() {
    _print i "java and javac"
    _spin &
    _aptinstall default-jre default-jdk
    _endspin $! $?
}

function _tilix() {
    _print i "tilix: a terminal emulator"
    _spin &
    _checkppa webupd8team/terminix
    # sudo add-apt-repository ppa:webupd8team/terminix -y > /dev/null
    sudo apt-get -qq update && _aptinstall tilix
    _endspin $! $?
}

function _setwlp() {
    local wlp="wallpapers/1.jpg" # my custom default wallpaper
    _checkfile $wlp
    local file="'file://$(readlink -e "${wlp}")'"
    _print s "Wallpaper ${FILE}"
    gsettings set org.gnome.desktop.background picture-uri "$file"
}

function _installfonts() {
    _print i "fonts"
    _spin &
    _aptinstall fonts-firacode
    _endspin $! $?
}

function _fzfconfig() {
    _checkfile fzf/fzf.config
    _print s "fzf configuration"
    cp -v --backup=numbered fzf/fzf.config ~/.fzf.config
}

function _fzf() {
    _print i "fzf: Fuzzy finder"
    _spin &
    git clone -q --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --key-bindings --completion --no-update-rc > /dev/null
    _endspin $! $?
}

function _fd() {
    _print i "fd: an improved version of find"
    _spin &
    wget -q https://github.com/sharkdp/fd/releases/download/v7.4.0/fd-musl_7.4.0_amd64.deb -O /tmp/fd.deb
    sudo dpkg -i /tmp/fd.deb > /dev/null
    _endspin $! $?
}

function _bat() {
    _print i "bat: a clone of cat with syntax highlighting"
    _spin &
    wget -q https://github.com/sharkdp/bat/releases/download/v0.12.1/bat-musl_0.12.1_amd64.deb -O /tmp/bat.deb
    sudo dpkg -i /tmp/bat.deb > /dev/null
    _endspin $! $?
}

function _rg() {
    _print i "rg: ripgrep recursive search for a pattern in files"
    _spin &
    wget -q https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb -O /tmp/rg.deb
    sudo dpkg -i /tmp/rg.deb > /dev/null
    _endspin $! $?
}

function _checkroot() {
    local msg="$(printf '%s\n' \
               "Would you like to have a completely unattended installation?"  \
               "This will execute the installer with sudo to elevate privileges.")"
    if [ "$EUID" -ne 0 ]; then
        if (whiptail --title "Installer Privileges" --yesno "$msg" 8 78); then
            echo -e "${thunder} Trying to get ${start_underline}${bold}${red}root${reset} access rights... "
            sudo -s "$0" "$@"
            exit $?
        fi
    fi
}

function _validateroot() {
    # This function will validate user's sudo timestamp without running any commnad
    # It will prompt for password and keep it in cache, which is 15 mins by default
    sudo -v
}

function _showmenu() {
    _checkcommand whiptail
    local INFO="---------------------- System Information -----------------------\n"
    INFO+="$(hostnamectl | tail -n 3 | cut -c3-)"
    INPUT=$(whiptail --title "This script provides an easy way to install my packages and my configurations." \
        --menu "\nScript is executed from '$(pwd)'\n\n${INFO}" ${SIZE} 3 \
        "1"  "    Fresh installation of everything" \
        "2"  "    Selective installation" \
        "Q"  "    Quit" \
        3>&1 1>&2 2>&3)
}

function _dconfgui() {
    local opt=$(whiptail --title "dconf settings" --menu "\nWhich dconf settings would you like to apply?" \
                ${SIZE} 3 \
                "1" "    dconf general settings" \
                "2" "    dconf general settings with themes" \
                "3" "    dconf tilix settings" \
                3>&1 1>&2 2>&3)
    case $opt in
        1) _dconfsettings ;;
        2) _dconfsettingswthemes ;;
        3) _dconftilix ;;
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
        "36" "    arc-theme" \
        "37" "    papirus icons and folder changer script" \
        "Q"  "    Quit" \
        3>&1 1>&2 2>&3)
}

# ----------------------------------------------------- Installers -----------------------------------------------------

function _fresh_install() {
    _checkcommand curl && _checkcommand git
    _installfonts
    _arctheme
    _papirusicons && _papirusfolders
    _zsh -y && _zshconfig && _omz
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
    _sublimetext && _sublimeinit && _sublimeconfig
    _vscode
    _googlechrome
    _preload
    _vmswappiness
    _dconf
    _setwlp
    _reboot
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
            29) _sublimeinit && _sublimeconfig ;;
            30) _vscode ;;
            31) _googlechrome ;;
            32) _preload ;;
            33) _vmswappiness ;;
            34) _setwlp ;;
            35) _installfonts ;;
            36) _arctheme ;;
            37) _papirusicons ;;
            Q | *) exit_status=1 ;;
        esac
        # Sleep only when user hasn't selected Quit
        [ $exit_status -eq 0 ] && sleep 2
    done
}

# ------------------------------------------------------- Main ---------------------------------------------------------

_validateroot
_showmenu

if [[ $INPUT -eq 1 ]]; then
    _fresh_install
elif [[ $INPUT -eq 2 ]]; then
    _selective_install
else
    exit 0
fi
