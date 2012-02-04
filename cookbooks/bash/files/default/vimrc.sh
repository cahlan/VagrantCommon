set nocompatible
set bs=2 "set backspace to be able to delete previous chars

set wrap! "turn off word wrap

"http://www.cyberciti.biz/faq/vi-show-line-numbers/
set number

"http://vim.wikia.com/wiki/Converting_tabs_to_spaces
"http://www.jonlee.ca/hacking-vim-the-ultimate-vimrc/
set smartindent
set tabstop=2
set shiftwidth=2
set expandtab
filetype indent on

"http://vim.wikia.com/wiki/Highlight_current_line
hi CursorColumn cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>
":set cursorline
":set cursorcolumn

hi LineNr term=underline cterm=bold ctermfg=3 guifg=Blue
syntax enable

"Informative status line
set statusline=%F%m%r%h%w\ [TYPE=%Y\ %{&ff}]\ [%l/%L\ (%p%%)]

set foldenable
set fdm=indent
nnoremap <space> za

colorscheme desert

