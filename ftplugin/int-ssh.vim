call vimshell#hook#add('preinput', 'vimshell_ssh', 'vimshell_ssh#pre')
call vimshell#hook#add('postinput', 'vimshell_ssh', 'vimshell_ssh#post')

if exists(':NeoComplCacheLockSource')
  NeoComplCacheLockSource filename_complete
endif
