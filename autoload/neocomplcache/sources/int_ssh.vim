let s:source = {
      \ 'name' : 'int-ssh',
      \ 'kind' : 'ftplugin',
      \ 'filetypes': { 'int-ssh': 1 },
      \ }
function! s:source.initialize() "{{{
endfunction "}}}

function! s:source.finalize() "{{{
endfunction "}}}

function! s:source.get_keyword_pos(cur_text)  "{{{
  return neocomplcache#sources#filename_complete#define().get_keyword_pos(a:cur_text)
endfunction "}}}

function! s:ls(x)
  let chunk = s:remoterun(printf("/bin/ls -1 --color=never %s 2>/dev/null", string(a:x)))
  "return chunk
  return split(chunk, "\n")[1:-2]
endfunction

function! s:remoterun(cmd)
  "while 1
  "  let chunk = b:interactive.process.read_lines(1000, 40)
  "  if chunk != []
  "    return chunk
  "  endif
  "endwhile
  "echomsg a:cmd
  call b:interactive.process.stdout.write(a:cmd . "\<Cr>")
  "return b:interactive.process.read_lines(1000, 40)
  let chunk = ''
  while stridx(chunk, "\n") < 0
    let chunk = b:interactive.process.stdout.read(1000, 40)
    "sleep 1m
  endwhile
  return substitute(chunk, "\r", '', 'g')
endfunction

function! s:source.get_complete_words(cur_keyword_pos, cur_keyword_str) "{{{
  if !s:is_on_prompt_line()
    return []
  endif
  let dir = fnamemodify(a:cur_keyword_str, ':h')
  let list = []
  for f in s:ls(dir)
    let name = dir . '/' . f
    call add(list, {'word': name, 'menu': '[ssh] ' . name})
  endfor
  return list
endfunction "}}}

function! s:is_on_prompt_line()
  return getline('.')[0 : getpos('.')[2]] =~ '^.*\$ '
endfunction

function! neocomplcache#sources#int_ssh#define() "{{{
  return s:source
endfunction "}}}

" vim: ts=2 sw=2 sts=2 foldmethod=marker
