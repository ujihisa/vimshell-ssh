function! vimshell_ssh#pre(input, context)
  if a:input !~# '^vim\s'
    return a:input
  endif

  "call vimshell#interactive#send_string("pwd\<Cr>")
  call b:interactive.process.write("pwd\<Cr>")
  let chunk = ''
  while chunk == ''
    let chunk = b:interactive.process.read(1000, 40)
    "sleep 1m
  endwhile
  let dir = split(chunk, "\n")[1]
  let dir = substitute(dir, "\r", '', '')
  let file = substitute(a:input, '^vim\s\+', '', '')

  execute printf('new scp://%s//%s/%s', s:args2hostname(b:interactive.args), dir, file)
  wincmd W

  let b:vim_ran = 1
  return ''
endfunction

function! vimshell_ssh#post(input, context)
  if a:input == '' && s:get('b:vim_ran')
    let b:vim_ran = 0
    wincmd w
  endif
endfunction

function! s:args2hostname(args)
  let xs = copy(a:args)
  call remove(xs, 0) " 1st item is always 'ssh'

  let port = ''
  let user = ''
  let machine = ''
  while xs != []
    let e = remove(xs, 0)
    if e ==# '-p'
      let port = ':' . remove(xs, 0)
    elseif e ==# '-u'
      let user = remove(xs, 0) . '@'
    else
      let machine = e
    endif
  endwhile
  return join([user, machine, port], '')
endfunction

function! s:get(varname)
  return exists(a:varname) ? eval(a:varname) : 0
endfunction
