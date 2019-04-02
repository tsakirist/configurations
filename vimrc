" Automate the process of installing vim-plug when required
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
     \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC 
endif

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.
Plug 'sheerun/vim-polyglot'
Plug 'vim-python/python-syntax'
"Plug 'vim-jp/vim-cpp'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'joshdick/onedark.vim'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

" Change linenumber coloring to white
augroup colorset
    autocmd!
    let s:white = { "gui": "#ABB2BF", "cterm": "145", "cterm16" : "7" }
    autocmd ColorScheme * call onedark#set_highlight("LineNr", { "fg": s:white }) " `bg` will not be styled since there is no `bg` setting
  augroup END

" Coloring configurations
syntax on
colorscheme onedark

"highlight LineNr term=bold cterm=None ctermfg=Red ctermbg=None

" This displays the line numbers and controls the number of columns used for the line number
set number
set numberwidth=1

" This is used to control the Ctrl + C command and copy to the system's clipboard
set clipboard=unnamedplus

" This inserts spaces when <Tab> is pressed. With this option set, if you want to enter a real tab character use Ctrl-V<Tab> key sequence
set expandtab

" This controls the number of space characters inserted when pressing the tab key
set tabstop=4

" This controls the number of space characeters inserted for identation
set shiftwidth=4

" These are required to enable powerline
set rtp+=/home/tsakiris/.local/lib/python2.7/site-packages/powerline/bindings/vim
set laststatus=2
set t_Co=256
