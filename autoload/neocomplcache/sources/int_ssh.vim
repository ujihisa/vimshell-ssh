let s:source = {
      \ 'name' : 'int-ssh',
      \ 'kind' : 'ftplugin',
      \ 'filetypes': { 'int-ssh': 1 },
      \ }
function! s:source.initialize() "{{{
  call neocomplcache#set_completion_length(self.name,
        \ g:neocomplcache_auto_completion_start_length)
endfunction "}}}

function! s:source.finalize() "{{{
endfunction "}}}

function! s:source.get_keyword_pos(cur_text)  "{{{
  let pattern = neocomplcache#get_keyword_pattern_end('filename')
  let [cur_keyword_pos, _] =
        \ neocomplcache#match_word(a:cur_text, pattern)
  return cur_keyword_pos
endfunction "}}}

function! s:ls(x)
  let chunk = vimshell_ssh#remoterun(
        \ printf("/bin/ls -1F %s 2>/dev/null", string(a:x)))
  "return chunk
  return split(chunk, "\n")
endfunction

function! s:source.get_complete_words(cur_keyword_pos, cur_keyword_str) "{{{
  if !s:is_on_prompt_line()
    return []
  endif

  let dir = a:cur_keyword_str =~ '/' ?
        \ fnamemodify(a:cur_keyword_str, ':h') . '/' : ''
  let list = []
  for f in s:ls(fnamemodify(a:cur_keyword_str, ':h'))
    let name = dir . f

    call add(list, { 'word': substitute(name, '[*|@]$', '', ''),
          \ 'menu': '[ssh] ' . name })
  endfor

  return neocomplcache#keyword_filter(list, a:cur_keyword_str)
endfunction "}}}

function! s:is_on_prompt_line()
  return s:get_line() =~ '^.*[$%] '
endfunction

function! s:get_line()
  return substitute(getline('.'), '\e\[[0-9;]*m', '', 'g')
endfunction

function! neocomplcache#sources#int_ssh#define() "{{{
  return has('reltime') ? s:source : {}
endfunction "}}}

" vim: ts=2 sw=2 sts=2 foldmethod=marker
