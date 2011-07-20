if version < 700
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn match IntSshPrompt '^.\{-}@.\{-}\$'

if has('gui_running')
  hi IntSshPrompt  gui=UNDERLINE guifg=#80ffff guibg=NONE
else
  hi def link IntSshPrompt Identifier
endif


let b:current_syntax = 'int-ssh'
