" https://vimdoc.sourceforge.net/htmldoc/syntax.html
" http://vimdoc.sourceforge.net/htmldoc/options.html

if has("gui_running")

  " Load color scheme {name}.
  colorscheme slate

  " https://github.com/tonsky/FiraCode/issues/462
  set guifont=Fira_Code:h11

  " This option only has an effect in the GUI version of Vim.
  " Menu bar is present.
  set guioptions -=m
  " Include Toolbar.
  set guioptions -=T
  " Right-hand scrollbar is always present.
  set guioptions -=r

endif

" When on, lines longer than the width of the window will wrap and
" displaying continues on the next line.  When off lines will not wrap
" and only part of long lines will be displayed.
set nowrap

" Print the line number in front of each line.
set number
" Show the line and column number of the cursor position, separated by a
" comma.
set ruler

" Ring the bell (beep or screen flash) for error messages.
set noerrorbells
" Use visual bell instead of beeping.
set novisualbell

" In Insert mode: Use the appropriate number of spaces to insert a
" <Tab>.  Spaces are used in indents with the '>' and '<' commands and
" when 'autoindent' is on.  To insert a real tab when 'expandtab' is
" on, use CTRL-V<Tab>.
set expandtab
" Number of spaces that a <Tab> in the file counts for.
set tabstop=4
" Number of spaces that a <Tab> counts for while performing editing
" operations, like inserting a <Tab> or using <BS>.
set softtabstop=4
" Number of spaces to use for each step of (auto)indent.
set shiftwidth=4

" Highlight the screen line of the cursor with CursorLine
" |hl-CursorLine|.
set cursorline
" the screen line that the cursor is in when 'cursorline' is
" set
highlight clear CursorLine
highlight CursorLineNR ctermbg=red

" When a bracket is inserted, briefly jump to the matching one.
set showmatch

" When there is a previous search pattern, highlight all its matches.
set hlsearch

" Influences the working of <BS>, <Del>, CTRL-W and CTRL-U in Insert
" mode.
set backspace=indent,eol,start
