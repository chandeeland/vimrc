
set nocompatible                " get out of horrible vi-compatible mode
set nocp
execute pathogen#infect()

" General
filetype on                    " detect the type of file
set history=1000                " How many lines of history to remember
set cf                        " enable error files and error jumping
set clipboard+=unnamed                " turns out I do like is sharing windows clipboard
set ffs=unix,dos,mac                " support all three, in this order
filetype plugin on                " load filetype plugins
set viminfo+=!                    " make sure it can save viminfo
set isk+=_,$,@,%,#,-                " none of these should be word dividers, so make them not be

" Theme/Colors
set background=dark                " we are using a dark background
syntax on                    " syntax highlighting on

" Files/Backups
set backup                    " make backup file
set backupdir=~/.vim/vimfiles/backup        " where to put backup file
set directory=~/.vim/vimfiles/temp        " directory is the directory for temp file
set makeef=error.err                " When using make, where should it dump the file

" UI
set lsp=0                " space it out a little more (easier to read)
set ruler                " Always show current positions along the bottom 
set cmdheight=2                " the command bar is 2 high
"set number                " turn on line numbers
set lz                " do not redraw while running macros (much faster) (LazyRedraw)
set hid                " you can change buffer without saving
set backspace=2                " make backspace work normal
set whichwrap+=<,>,h,l             " backspace and cursor keys wrap to
set shortmess=atI            " shortens messages to avoid 'press a key' prompt 
set report=0                " tell us when anything is changed via :...
set noerrorbells            " don't make noise
     " make the splitters between windows be blank
set fillchars=vert:\ ,stl:\ ,stlnc:\ 

" Visual Cues
set showmatch                " show matching brackets
set mat=5                " how many tenths of a second to blink matching brackets for
set nohlsearch                " do not highlight searched for phrases
set incsearch                " BUT do highlight as you type you search phrase
set listchars=tab:\|\ ,trail:.,extends:>,precedes:<,eol:$                " what to show when I hit :set list
"set lines=80                " 80 lines tall
"set columns=160                " 160 cols wide
set so=10                " Keep 10 lines (top/bottom) for scope
set novisualbell            " don't blink
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
set laststatus=2            " always show the status line

" Text Formatting/Layout
set fo=tcrqn                " See Help (complex)
"set ai                    " autoindent
"set nosmarttab                " use tabs at the start of a line, spaces elsewhere
"set smarttab
set nowrap                " do not wrap lines  
    
" Folding
"    Enable folding, but by default make it act like folding is off, because folding is annoying in anything but a few rare cases
set foldenable                " Turn on folding
set foldmethod=indent                " Make folding indent sensitive
set foldlevel=100                " Don't autofold anything (but I can still fold manually)
set foldopen-=search                " don't open folds when you search into them
set foldopen-=undo                " don't open folds when you undo stuff

" File Explorer
let g:explVertical=1                " should I split verticially
let g:explWinSize=35                " width of 35 pixels

" Win Manager
let g:winManagerWidth=35                " How wide should it be( pixels)
let g:winManagerWindowLayout = 'FileExplorer,TagsExplorer|BufExplorer'                " What windows should it

" CTags
let Tlist_Ctags_Cmd = $VIM.'\ctags.exe'                " Location of ctags
let Tlist_Sort_Type = "name"                " order by 
let Tlist_Use_Right_Window = 1                " split to the right side of the screen
let Tlist_Compart_Format = 1                " show small meny
let Tlist_Exist_OnlyWindow = 1                " if you are the last, kill yourself
let Tlist_File_Fold_Auto_Close = 0                " Do not close tags for other files
let Tlist_Enable_Fold_Column = 0                " Do not show folding tree

" Minibuf
let g:miniBufExplTabWrap = 1                " make tabs show complete (no broken on two lines)
let g:miniBufExplModSelTarget = 1

" Matchit
let b:match_ignorecase = 1

" Perl
let perl_extended_vars=1                " highlight advanced perl vars inside strings

" Custom Functions
" Select range, then hit :SuperRetab($width) - by p0g and FallingCow
function! SuperRetab(width) range
silent! exe a:firstline . ',' . a:lastline . 's/\v%(^ *)@<= {'. a:width .'}/\t/g'
endfunction

""
" Boinks up a blame window for the currently loaded file.
" @return void
""
function SvnBlame_blameCurrentFile()
  let fileName = expand('%')
  if match(fileName, "_svnBlame$") == -1
    let blameBufferName = fileName."_svnBlame"
    let blameBuffer = bufnr(blameBufferName)
    if blameBuffer == -1
      call SvnBlame_openBlameBuffer(fileName, blameBufferName)
    else
      wincmd w
      call SvnBlame_execPreserveNum('bwipeout '.blameBuffer)
    endif
  else
    " We're in a blame buffer, so close it.
    call SvnBlame_execPreserveNum('bwipeout '.fileName)
  endif
endfunction

""
" Execs the given command, preserving numbering
" @param string commandString
" @return void
function SvnBlame_execPreserveNum(commandString)
    if &number == 1
        let numbered = 1
    else
        let numbered = 0
    endif
    exe a:commandString
    if numbered == 1
        set nu
    endif
endfunction

""
" Opens up a blame buffer called blameBufferName for the given fileName
" @param string fileName The filename to blame
" @param string blameBufferName The name to use for the blame buffer
" @return void
function SvnBlame_openBlameBuffer(fileName, blameBufferName)
    set scrollbind
    set nowrap
    call SvnBlame_execPreserveNum("15vnew ".a:blameBufferName)
    " Current window is now the blame buffer
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal autoread
    set scrollbind
    set nowrap
    "Set filetype so that any special syntax files can be included.
    setf blame
    execute 'silent read !svn blame '.a:fileName.' | sed -n -e "s/\s\([0-9]\+\)\s\+\(\S\+\).*/\2 (\1)/p"'
    "Delete first line, which is empty.
    1d
    "Make the buffer non-modifiable.
    setlocal nomodifiable
    "Switching out, in then out of the blame buffer seems to force an auto-resize.
    wincmd w
    wincmd w
    wincmd w
    set nonu
endfunction

" Mappings
map <A-i> i <ESC>r                    " alt-i (normal mode) inserts a single char, and then switches back to normal

nnoremap <F1> :set invpaste paste?<CR>
set pastetoggle=<F1>
set showmode

map <F2> :s/,/\r    ,/g<CR>		" F2 breaks up long lines along a comma.

map <F3> <ESC>ggVG:call SuperRetab()<left>
map <F4> <ESC>:call SvnBlame_blameCurrentFile()<CR>
map <F11> se rl!                " reverse script (toggle)
map <F12> ggVGg?                " encypt the file (toggle)

" Autocommands
autocmd BufEnter * :syntax sync fromstart                " ensure every file does syntax highlighting (full)
au BufNewFile,BufRead *.asp :set ft=aspjscript                " all my .asp files ARE jscript
au BufNewFile,BufRead *.tpl :set ft=html                " all my .tpl files ARE html
au BufNewFile,BufRead *.hta :set ft=html                " all my .tpl files ARE html
au BufNewFile,BufRead *.ssa :set ft=php                    " all my .ssa files ARE php
"
" prevents auto EOL after last line (just EOF)
"
set noeol
set binary

" hard tabs only
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smartindent
set autoindent
set expandtab
"set cindent

" highlight unwanted tabs
highlight STUPIDTABS ctermbg=blue
match STUPIDTABS /\t/

