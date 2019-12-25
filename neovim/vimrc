"--------------------------------------------------------------------------------------------------
" These are common keyboard shortcuts to remind myself
" <C-n> multiple cursors, <C-n> again to go to next, <C-x> to remove current cursor
" <Shift+i> toggle hidden files in NERDTree
" [count]\cc, comments out current line or count lines
" [count]\cu, uncomments the current line or count lines
" [count]<leader>c<space> Toggles the comment state of the lines
"--------------------------------------------------------------------------------------------------

" ---------------------------------- Plugin installer configurations ------------------------------

" Automate the process of installing vim-plug when required
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
     \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins will be downloaded under the specified directory
call plug#begin('~/.vim/plugged')

" Declare the list of plugins
Plug 'joshdick/onedark.vim'
Plug 'sjl/badwolf'
Plug 'sheerun/vim-polyglot'
Plug 'vim-python/python-syntax'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'scrooloose/nerdcommenter'
Plug 'terryma/vim-multiple-cursors'
Plug 'scrooloose/nerdtree'
Plug 'mhinz/vim-signify'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Yggdroot/indentLine'

" Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}

" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Plug 'deoplete-plugins/deoplete-jedi'
" Plug 'ervandew/supertab'

" List ends here. Plugins become visible to Vim after this call
call plug#end()

" ------------------------------------- General Configurations ------------------------------------

" Function to zoom-in and zoom-out from a window
function! s:ZoomToggle() abort
    if exists('t:zoomed') && t:zoomed
        execute t:zoom_winrestcmd
        let t:zoomed = 0
    else
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
        let t:zoomed = 1
    endif
endfunction

" Function to trim trailing whitespace
" https://vi.stackexchange.com/a/456
function! TrimTrailWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfunction

" Function to make a whole word search faster
function! SearchWord(word)
    let @/ = '\<' . a:word . '\>'
    normal n
endfunction

" Coloring configurations
syntax on
silent! colorscheme onedark
" silent! colorscheme badwolf

"highlight LineNr term=bold cterm=None ctermfg=Red ctermbg=None

" This displays the line numbers and controls the number of columns used for the line number
set number
set numberwidth=1

" This is used to control the Ctrl + C command and copy to the system's clipboard
set clipboard=unnamedplus

" Insert spaces when <Tab> is pressed. With this option set, if you want to enter a real tab character use Ctrl-V<Tab>
" key sequence
set expandtab

" Controls the number of space characters inserted when pressing the tab key
set tabstop=4

" Controls the number of space characters inserted for identation
set shiftwidth=4

" This makes searches case insensitive
set ignorecase

" This makes searches with a single capital letter to be case sensitive
set smartcase

" Highlight the current line and also highlight the column @120 (ruler)
set colorcolumn=120
highlight colorcolumn ctermbg=black
set cursorline

" Open windows always below or right
set splitbelow
set splitright

" Set the maximum text width before vim automatically wraps it
set textwidth=120

" Format options configuration:
" 't' is required in format options to wrap text in insert mode
" if a line is longer than textwidth it may not be wraped if 'l' is in format options
" Disable <CR> key from autocommenting when pressing enter in a commented line
autocmd BufEnter * set fo+=t fo-=r

" Remove trailing whitespaces on file save
autocmd BufWritePre * :call TrimTrailWhitespace()

" This is used to preserve the clipboard when vim exits
autocmd VimLeave * call system("xclip -selection clipboard -i", getreg("+"))

" Close NERDTree automatically when it is the only window left open
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Groupped configurations of :term
augroup TerminalConfigs
    " Clear old autocommands of this group
    autocmd!
    " Automatically enter in insert mode when in terminal pane
    autocmd TermOpen,BufEnter,WinEnter * if &buftype == 'terminal' | :startinsert | endif
    " Disable linenumbering when in terminal
    autocmd TermOpen * setlocal nonumber norelativenumber
augroup END

" Change linenumber coloring to white
augroup colorset
    autocmd!
    let s:white = { "gui": "#ABB2BF", "cterm": "145", "cterm16" : "7" }
    autocmd ColorScheme * call onedark#set_highlight("LineNr", { "fg": s:white })
augroup END

" Open NERDTree automatically when vim starts
"autocmd vimenter * NERDTree
"
" Add space after commenting with NerdCommenter
let g:NERDSpaceDelims=1

" Change the delete sign of git-signify from '_' to '-'
let g:signify_sign_delete='-'

" let g:airline_theme='term'
let g:airline_theme='solarized_flood'

" ------------------------------------------ Keybindings ------------------------------------------

" Keybinds to move lines like sublime text 3
" https://vim.fandom.com/wiki/Moving_lines_up_or_down
" gv=gv re-selects the visual block after each operation
nnoremap <silent> <C-S-Up> :m-2<CR>
nnoremap <silent> <C-S-Down> :m+<CR>
inoremap <silent> <C-S-Up> <Esc>:m-2<CR>
inoremap <silent> <C-S-Down> <Esc>:m+<CR>
vnoremap <silent> <C-S-Up> :m '<-2<CR>gv=gv
vnoremap <silent> <C-S-Down> :m '>+1<CR>gv=gv

" Duplicate the current line
" 'm' sets a mark that we can return afterwards by using '`' followed by the mark's name
" :normal properly handles a [count] prepended before the command e.g. 3w, 5d etc
" http://vimcasts.org/episodes/creating-mappings-that-accept-a-count/
nnoremap <leader>d  :normal m`yyp``<CR>
inoremap <leader>d <Esc>m`yyp``<CR>A
vnoremap <leader>d <Esc>m`yyp``<CR>

" Hitting ESC when inside a :term to get into normal mode
tnoremap <Esc> <C-\><C-N>

" Set this keyboard combination to toggle NERDTree, it's the same as Sublime Text 3
map <silent> <C-k><C-b> :NERDTreeToggle<CR>

" Insert a blank line with <leader>Enter without leaving normal mode
nnoremap <silent> <leader><CR> o<Esc>

" Save files with ctrl+s
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>
vnoremap <C-s> <Esc>:w<CR>

" Easiliy toggle comments @NERDCommenter
map <leader><leader> <leader>c<Space><CR>
" Toggling comment in insert mode keeps insert mode :startinsert
imap <leader><leader> <Esc><leader>c<Space>:startinsert<CR>

" Clear highlighting with escape when in normal mode
nnoremap <silent> <esc> :noh<return><esc>
nnoremap <silent> <esc>^[ <esc>^[

" Keymap to source the vimrc automatically
nnoremap <silent> <leader>sc :source $MYVIMRC<CR>

" Keymaps to quit current buffer with Ctrl+q
nnoremap <silent> <C-q> <Esc>:q<CR>
inoremap <silent> <C-q> <Esc>:q<CR>
vnoremap <silent> <C-q> <Esc>:q<CR>

" Commands/Keymaps to open terminals horizontally and vertically
command! -nargs=* HT split  | terminal <args>
command! -nargs=* VT vsplit | terminal <args>

nnoremap <silent> <leader>ht :HT<CR>
nnoremap <silent> <leader>vt :VT<CR>

" Make the whole-word search proc with <leader>/
command! -nargs=1 SearchWord call SearchWord(<f-args>)
nnoremap <leader>/ :SearchWord

" Command and key mapping to enable the zoom-in and zoom-out
command! ZoomToggle call s:ZoomToggle()
nnoremap <silent> <leader>z :ZoomToggle<CR>

" Add mouse support and change the default mouse scrolling wheel options
set mouse=a
nnoremap <ScrollWheelDown> 4<C-e>
xnoremap <ScrollWheelUp>   4<C-y>
xnoremap <ScrollWheelDown> 4<C-e>

" ---------------------------------------- COC Intelisense ----------------------------------------
" source ~/.vim/coc/coc.config.vim
