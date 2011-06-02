if exists('g:loaded_vimshell_ssh')
  finish
endif
let s:save_cpo = &cpo
set cpo&vim

autocmd FileType int-ssh
      \ call vimshell#hook#set('preinput', ['vimshell_ssh#pre']) |
      \ call vimshell#hook#set('postinput', ['vimshell_ssh#post'])

let &cpo = s:save_cpo
unlet s:save_cpo
let g:loaded_vimshell_ssh = 1
