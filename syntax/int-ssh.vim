if version < 700
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn match vimShellSshPrompt '^.\{-}@.\{-}[$%] '

if has('gui_running')
  hi vimShellSshPrompt  gui=UNDERLINE guifg=#80ffff guibg=NONE
else
  hi def link vimShellSshPrompt Identifier
endif


let b:current_syntax = 'int-ssh'
