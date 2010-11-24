let mapleader=","

" update .vimrc on the fly

nmap <leader>v :tabedit $MYVIMRC<CR>
nmap <leader>V :source $MYVIMRC<CR>

call pathogen#runtime_append_all_bundles()

set nowrap
set hidden
set shortmess=aOstT " shortens messages to avoid 'press a key' prompt
set showcmd " show the command being typed

set wildmenu
set wildmode=list:longest

set shell=bash
set fileformats=unix
set ff=unix

set backup
set backupdir=/private/tmp
set dir=/private/tmp

set novisualbell
set scrolloff=5

" spelling
"if v:version >= 700
"   " Enable spell check for text files
"     autocmd BufNewFile,BufRead *.txt setlocal spell spelllang=en
"endif

set nocompatible
set ttyfast
set autochdir

set cul
hi CursorLine term=none cterm=none ctermbg=3

set more

set enc=utf-8  " Default encoding

if version >= 700
    au InsertEnter * hi StatusLine term=reverse ctermbg=5 gui=undercurl guisp=Magenta
    au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=2 gui=bold,reverse
endif

set expandtab
set textwidth=79
set tabstop=8
set softtabstop=4
set shiftwidth=4
set autoindent

set title  " Set descriptive window/terminal title
set titlestring=%f%(\ [%M]%)

set splitright
set splitbelow
set noerrorbells      " Error bells are annoying
set report=0          " Always report the number of lines changed
set display=lastline  " Show as much of the last line as possible

syntax on
set number
filetype plugin indent on
filetype on

set showmatch
set mat=2
set ruler
set incsearch
set hlsearch
set history=1000
set undolevels=1000

set list        " Show certain nonprinting characters
set listchars=  " Defines how hidden chars are shown when in 'list' mode.

set lcs+=tab:▷⋅      " Right triangle and middle dot for tab chars
set lcs+=extends:›   " Right single angle for chars right of the screen
set lcs+=precedes:‹  " Left single angle for chars left of the screen
set lcs+=nbsp:·      " Middle dot for non-breaking spaces
set lcs+=trail:·     " Middle dot for trailing spaces

color xoria256

let python_highlight_all=1
" highlight bad eols
highlight WhitespaceEOL ctermbg=red guibg=red
match WhitespaceEOL /\s\+$/

set laststatus=2 " show always
"set statusline=
"set statusline+=%-3.3n\                      " buffer number
"set statusline+=%f\                          " filename
"set statusline+=%h%m%r%w                     " status flags
"set statusline+=\[%{strlen(&ft)?&ft:'none'}] " file type
"set statusline+=\ %{fugitive#statusline()}     " fugitive
"set statusline+=%=                           " right align remainder
"set statusline+=0x%-8B                       " character value
"set statusline+=%-14(%l,%c%V%)               " line, character
"set statusline+=%<%P                         " file position

" {{{ Nice statusbar
"statusline setup
set statusline=%f       "tail of the filename

"display a warning if fileformat isnt unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*

"display a warning if file encoding isnt utf-8
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*

set statusline+=%h      "help file flag
set statusline+=%y      "filetype
set statusline+=%r      "read only flag
set statusline+=%m      "modified flag

" display current git branch
set statusline+=%{fugitive#statusline()}

"display a warning if &et is wrong, or we have mixed-indenting
set statusline+=%#error#
set statusline+=%{StatuslineTabWarning()}
set statusline+=%*

set statusline+=%{StatuslineTrailingSpaceWarning()}

set statusline+=%#warningmsg#
set statusline+=%*

"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*

set statusline+=%=      "left/right separator
set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
set laststatus=2        " Always show status line

"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
    if !exists("b:statusline_trailing_space_warning")
        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[\s]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif
    return b:statusline_trailing_space_warning
endfunction

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let tabs = search('^\t', 'nw') != 0
        let spaces = search('^ ', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        else
            let b:statusline_tab_warning = ''
        endif
    endif
    return b:statusline_tab_warning
endfunction

"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    if !exists("b:statusline_long_line_warning")
        let long_line_lens = s:LongLines()

        if len(long_line_lens) > 0
            let b:statusline_long_line_warning = "[" .
                        \ '#' . len(long_line_lens) . "," .
                        \ 'm' . s:Median(long_line_lens) . "," .
                        \ '$' . max(long_line_lens) . "]"
        else
            let b:statusline_long_line_warning = ""
        endif
    endif
    return b:statusline_long_line_warning
endfunction

"return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)

    let long_line_lens = []

    let i = 1
    while i <= line("$")
        let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
        if len > threshold
            call add(long_line_lens, len)
        endif
        let i += 1
    endwhile

    return long_line_lens
endfunction

"find the median of the given array of numbers
function! s:Median(nums)
    let nums = sort(a:nums)
    let l = len(nums)

    if l % 2 == 1
        let i = (l-1) / 2
        return nums[i]
    else
        return (nums[l/2] + nums[(l/2)-1]) / 2
    endif
endfunction;

set backspace=indent,eol,start
set ignorecase
set smartcase

autocmd BufWritePre * :%s/\s\+$//e
autocmd BufWritePre *.py normal m`:%s/\s\+$//e ``
set wildignore+=*.o,*.obj,.git,*.pyc
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
set omnifunc=pythoncomplete#Complete
set completeopt=longest,menuone

nnoremap ; :

map <buffer> <leader>r :w<CR>:!/usr/bin/env python % <CR>

map gp :.!python<CR>
vmap gp :!python<CR>

map <S-Left> <ESC>:tabp<cr>
map <S-Right> <ESC>:tabn<cr>

set pastetoggle=<F3>

" make indenting visual selection re-select
vmap > >gv
vmap < <gv

" Always jump to the last known cursor position.
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

" search pythonpath on gf
python << EOF
import os
import sys
import vim
for p in sys.path:
    # Add each directory in sys.path, if it exists.
    if os.path.isdir(p):
        # Command 'set' needs backslash before each space.
        vim.command(r"set path+=%s" % (p.replace(" ", r"\ ")))
EOF
