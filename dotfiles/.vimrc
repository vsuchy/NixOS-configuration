" --- General ---

set hidden          " A buffer becomes hidden when it is abandoned.

filetype indent on  " Enable loading the indent file for specific file types.
filetype plugin on  " Enable loading the plugin files for specific file types.

" --- Files / Backups ---

set encoding=utf-8    " Set the character encoding used inside Vim to UTF-8.
set fileformat=unix   " Set the <EOL> format to unix (<NL>).

set nobackup          " Don't make a backup before overwriting a file.
set nowritebackup     " Don't make a backup before overwriting a file.
set noswapfile        " Don't use a swapfile.
set viminfofile=NONE  " Don't read / write the viminfo file.

" --- Text formatting ---

set tabstop=2      " Number of spaces that a <Tab> in the file counts for.
set shiftwidth=2   " Number of spaces to use for each step of (auto)indent.
set softtabstop=2  " Number of spaces that a <Tab> counts for while performing editing operations.

set expandtab      " Use the appropriate number of spaces to insert a <Tab>.
set autoindent     " Copy indent from current line when starting a new line.
set smartindent    " Do smart autoindenting when starting a new line.

" --- Vim UI ---

set number     " Print the line number in front of each line.
set ruler      " Show the line and column number of the cursor position.
set report=0   " Threshold for reporting number of lines changed by : commands.

set nowrap     " Lines will not wrap.
set showmatch  " When a bracket is inserted, briefly jump to the matching one.

syntax on      " Enable syntax highlighting.

" --- Search ---

set ignorecase  " Ignore case in search patterns.
set smartcase   " Override the ignorecase option if the search pattern contains upper case characters.
set incsearch   " While typing a search command, show where the pattern matches.
set hlsearch    " When there is a previous search pattern, highlight all its matches.

" --- Auto commands ---

function! <SID>FormatWhitespace()
  let line = line(".")
  let column = col(".")

  retab
  %s/\s\+$//e

  call cursor(line, column)
endfun

autocmd BufWritePre * :call <SID>FormatWhitespace()
