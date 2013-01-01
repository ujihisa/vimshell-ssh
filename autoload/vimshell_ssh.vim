let g:vimshell_ssh#enable_debug = get(g:, 'vimshell_ssh#enable_debug', 0)

function! vimshell_ssh#pre(input, context)
  if b:interactive.command !=# 'ssh'
        \ || a:input !~# '^vim\>'
        \ || !has('reltime')
        \ || !has_key(b:interactive.prompt_history, line('.'))
    return a:input
  endif

  let prompt = b:interactive.prompt_history[line('.')]

  let dir = vimshell_ssh#remoterun('pwd')
  let dir = substitute(dir, '\r\|\n', '', 'g')
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

  sleep 100ms

  call vimshell#restore_pos(old_pos)

  call append('.', prompt)
  call cursor(line('.')+1, 0)
  let b:interactive.output_pos = getpos('.')
  let b:interactive.prompt_history[line('.')] = prompt

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

function! vimshell_ssh#remoterun(cmd)
  call b:interactive.process.stdout.write(a:cmd . "\<CR>")

  let chunk = ''
  let start = reltime()
  while 1
    let chunk .= b:interactive.process.stdout.read(1000, 100)

    if g:vimshell_ssh#enable_debug
      echomsg string(chunk)
    endif

    " Timeout
    let end = split(reltimestr(reltime(start)))[0] * 700
    if end > 700
      break
    endif

    let chunk = substitute(chunk, '\e\[[0-9;]*m', '', 'g')

    let chunks = split(chunk, "\n")
    if len(chunks) >= 3 && chunk =~ '[$%] '
      break
    endif
  endwhile

  " Delete colors.
  let chunk = substitute(chunk, '\e\[[0-9;]*m', '', 'g')

  let chunk = join(split(substitute(
        \ chunk, "\r", '', 'g'), '\n')[1 : -2], "\n")

  if g:vimshell_ssh#enable_debug
    echomsg string(chunk)
  endif

  return chunk
endfunction

function! s:get(varname)
  return exists(a:varname) ? eval(a:varname) : 0
endfunction
