# vimshell-ssh

## usage

1. `iexe ssh` on your vimshell
2. use `vim` command remotely
3. wow!

## dependencies

* vimshell
* netrw (should be built-in in your Vim)

## known issues

* netrw uses `:!`
    * solution:
    * use [my forked version of netrw](https://github.com/ujihisa/netrw.vim)
* netrw changes options like cursorline
    * solution:
    * write `let g:netrw_cursorline = 0` in your vimrc
    * or use [my forked version of netrw](https://github.com/ujihisa/netrw.vim)
* after vim command the ssh iexe buffer cursor location will be still in the vim command's line

## Author

Tatsuhiro Ujihisa
