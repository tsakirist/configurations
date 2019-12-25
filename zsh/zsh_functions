
# ----------------------------------------------------- Functions -----------------------------------------------------

# NOTE:
# The defined functions below follow the POSIX standard for functions.
# i.e. without using the keyword `function`

# This function returns an approximation of the memory usage of a process
# https://stackoverflow.com/questions/3853655/in-linux-how-to-tell-how-much-memory-processes-are-using
mem () {
    ps -eo rss,pid,euser,args:100 --sort %mem | grep --color=auto -v grep | grep --color=auto -i $@ \
        | awk '{printf $1/1024 " MB"; $1=""; print }'
}

# This function extracts any archive supplied as argument
extract () {
    for archive in $*; do
        if [ -f $archive ] ; then
            case $archive in
                *.tar.bz2)   tar xvjf $archive   ;;
                *.tar.gz)    tar xvzf $archive   ;;
                *.bz2)       bunzip2 $archive    ;;
                *.rar)       rar x $archive      ;;
                *.gz)        gunzip $archive     ;;
                *.tar)       tar xvf $archive    ;;
                *.tbz2)      tar xvjf $archive   ;;
                *.tgz)       tar xvzf $archive   ;;
                *.zip)       unzip $archive      ;;
                *.Z)         uncompress $archive ;;
                *.7z)        7z x $archive       ;;
                *)           echo "Don't know how to extract '$archive' ..." ;;
            esac
        else
            echo "'$archive' is not a valid file!"
        fi
    done
}

# This command serves the contents of the passed directory in an HTTP server at port:8000
serve() {
    if [[ $# -ne 0 ]]; then
        if [ ! -d "$1" ]; then
            echo "ERROR: '$1' is not a valid directory."
            return 1
        fi
        saved_path=$(pwd)
        cd $1
        served_path=$(pwd)
        echo "Serving '$served_path' ..."
        echo "IP: $(hostname -I)"
        python3 -m http.server
        cd $saved_path
    else
        echo "Serving current directory '.'"
        echo "IP: $(hostname -I)"
        python3 -m http.server
    fi
}

# This fixes the permissions on files and directories
perms() {
    if [[ $# -eq 0 ]]; then
        dest=.
    else
        dest=$1
    fi
    find "$dest" -type d | xargs chmod -v 755
    find "$dest" -type f | xargs chmod -v 644
}
