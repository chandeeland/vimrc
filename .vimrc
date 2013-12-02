
set nocompatible                " get out of horrible vi-compatible mode
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
"set fo=tcrqn                " See Help (complex)
set nowrap                " do not wrap lines  
set smarttab                
"set nosmarttab
"set smartindent
"set ai                    " autoindent
"set autoindent
set cindent                " smartest auto indent (for c like languages)
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab


" prevents auto EOL after last line (just EOF)
set noeol

" highlight unwanted tabs
highlight STUPIDTABS ctermbg=blue
match STUPIDTABS /\t/


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

" F1 toggles paste mode
nnoremap <F1> :set invpaste paste?<CR>
set pastetoggle=<F1>
set showmode

" F2 toggles line numbers
nmap <F2> :set invnumber<CR>

" F3 auto document php block
map <F3> <ESC>:exec PhpDoc()<CR>i

" F4 auto retab to 4 spaces
map <F4> <ESC>ggVG:call SuperRetab(4)<left>

" F5 Blame
"map <F5> <ESC>:call SvnBlame_blameCurrentFile()<CR>
map <F5> <ESC>:Gblame<CR>

" pretty format json
map <F6> <ESC>:%s/\([,[\]{}]\)/\1\r/g<CR>:%s/\([}\]]\)/\r\1/g<CR><ESC>:set syntax=json<CR><ESC>ggVG=

" F7 make long CSV's readable
map <F7> <ESC>:s/,/\r    ,/g<CR>     " F2 breaks up long lines along a comma.

" Spacebar folds
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf

map <F11> <ESC>:se rl!<CR>                " reverse script (toggle)
map <F12> <ESC>ggVGg?                " encypt the file (toggle)

" Autocommands
autocmd BufEnter * :syntax sync fromstart                " ensure every file does syntax highlighting (full)
au BufNewFile,BufRead *.asp :set ft=aspjscript                " all my .asp files ARE jscript
au BufNewFile,BufRead *.tpl :set ft=html                " all my .tpl files ARE html
au BufNewFile,BufRead *.hta :set ft=html                " all my .tpl files ARE html
au BufNewFile,BufRead *.ssa :set ft=php                    " all my .ssa files ARE php


" php-doc modded values

" Whether or not to automatically add the function end comment (1|0)
let g:pdv_cfg_autoEndFunction = 0
" Whether or not to automatically add the class end comment (1|0)
let g:pdv_cfg_autoEndClass = 0
let g:pdv_cfg_Type = "mixed" 
let g:pdv_cfg_Package = "" 
let g:pdv_cfg_Version = "$id$" 
let g:pdv_cfg_Author = "David Chan <dchan@mshanken.com>" 
let g:pdv_cfg_Copyright = strftime('%Y') . " Mshanken Communications" 
let g:pdv_cfg_License = "BSD-3 {@link https://github.com/mshanken/metamodel/blob/master/LICENSE.md}" 

let g:pdv_cfg_ReturnVal = "void" 


"set binary             " this is for binary file edits, revokes expandtab

"PHP qa

"let g:phpqa_php_cmd='/path/to/php'
"let g:phpqa_messdetector_ruleset = "/path/to/phpmd.xml"
"let g:phpqa_codesniffer_cmd='/path/to/phpcs'
"let g:phpqa_messdetector_cmd='/path/to/phpmd'

let g:phpqa_messdetector_autorun = 1
let g:phpqa_codesniffer_autorun = 0
let g:phpqa_codecoverage_autorun = 0

"let g:phpqa_codecoverage_file = "/path/to/clover.xml"

"let g:phpqa_messdetector_ruleset="codesize,unusedcode,naming"
let g:phpqa_messdetector_ruleset="unusedcode,naming"

let g:phpqa_codesniffer_args=" --standard=/home/dchan/.vim/codesniffer_rules.xml"
