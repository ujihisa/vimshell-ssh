let g:vimshell_ssh#enable_debug = get(g:, 'vimshell_ssh#enable_debug', 0)

function! vimshell_ssh#pre(input, context)
  if b:interactive.command ==# 'ssh' && a:input !~# '^vim\>'
    return a:input
  endif

  call b:interactive.process.stdout.write("pwd\<CR>")
  let chunk = ''
  while len(split(chunk, "\n")) < 2
    let chunk .= b:interactive.process.stdout.read(1000, 40)
    "sleep 1m

    if g:vimshell_ssh#enable_debug
      echomsg string(chunk)
    endif
  endwhile

  if g:vimshell_ssh#enable_debug
    echomsg string(chunk)
  endif

  let dir = split(chunk, "\n")[1]
  let dir = substitute(dir, "\r", '', '')
  let file = substitute(a:input, '^vim\s*', '', '')
  let file = substitute(file, '\r\|\n', '', 'g')

  if g:vimshell_ssh#enable_debug
    echomsg string(file)
  endif

  let [new_pos, old_pos] = vimshell#split(g:vimshell_split_command)
  " NOTE: passive check. Should we check aggressively?

  if !empty(unite#get_all_sources('ssh')) && exists(':VimFiler')
    let command = printf('%s://%s/%s/%s',
          \ 'VimFiler ssh',
          \ s:args2hostname(b:interactive.args),
          \ dir,
          \ file)
  else
    let command = printf('%s://%s//%s/%s',
          \ 'edit scp',
          \ s:args2hostname(b:interactive.args),
          \ dir,
          \ file)
  endif
  if g:vimshell_ssh#enable_debug
    echomsg command
  endif
  execute command
  call vimshell#restore_pos(old_pos)

  call append('.', '')
  call cursor(line('.')+1, 0)
  let b:interactive.output_pos = getpos('.')

  call vimshell#interactive#check_current_output()

  let b:vim_ran = 1
  return ''
endfunction

function! vimshell_ssh#post(input, context)
  if !(a:input == '' && s:get('b:vim_ran'))
    return
  endif

  let b:vim_ran = 0
  wincmd w
  stopinsert
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
