let g:vimshell_ssh#enable_debug = get(g:, 'vimshell_ssh#enable_debug', 0)

function! vimshell_ssh#pre(input, context)
  if a:input !~# '^vim\>'
    return a:input
  endif

  "call vimshell#interactive#send_string("pwd\<Cr>")
  call b:interactive.process.stdout.write("pwd\<Cr>")
  let chunk = ''
  while len(split(chunk, "\n")) < 2
    let chunk = b:interactive.process.stdout.read(1000, 40)
    "sleep 1m
  endwhile
  if g:vimshell_ssh#enable_debug
    echomsg string(chunk)
  endif

  let dir = split(chunk, "\n")[1]
  let dir = substitute(dir, "\r", '', '')
  let file = substitute(a:input, '^vim\s*', '', '')

  if g:vimshell_ssh#enable_debug
    echomsg file
  endif

  let [new_pos, old_pos] = vimshell#split(g:vimshell_split_command)
  " NOTE: passive check. Should we check aggressively?
  let cmdprotocol = exists('*unite#sources#ssh#define') ?
        \ 'Unite ssh' :
        \ 'edit scp'
  let cmdprotocol = 'edit scp' " temporary
  let command = printf('%s://%s//%s/%s',
        \ cmdprotocol,
        \ s:args2hostname(b:interactive.args),
        \ dir,
        \ file)
  if g:vimshell_ssh#enable_debug
    echomsg command
  endif
  execute command
  call vimshell#restore_pos(old_pos)

  let b:vim_ran = 1
  return ''
endfunction

function! vimshell_ssh#post(input, context)
  if a:input == '' && s:get('b:vim_ran')
    let b:vim_ran = 0
    wincmd w
    stopinsert
  endif
endfunction

" s:args2hostname(['ssh', 'example.com'])
" => 'example.com'
" s:args2hostname(['ssh', '-p', '2222', 'example.com'])
" => 'example.com:2222'
" s:args2hostname(['ssh', '-u', 'ujihisa', 'example.com'])
" => 'ujihisa@example.com'
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
