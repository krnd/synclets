" http://vimdoc.sourceforge.net/htmldoc/options.html

" When on, lines longer than the width of the window will wrap and
" displaying continues on the next line.  When off lines will not wrap
" and only part of long lines will be displayed.
set nowrap

" Print the line number in front of each line.
set number
" Show the line and column number of the cursor position, separated by a
" comma.
set ruler

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

" When a bracket is inserted, briefly jump to the matching one.
set showmatch

" When there is a previous search pattern, highlight all its matches.
set hlsearch
