function! OpenObjectContent(content, buffer)
  call bufadd(a:buffer)
  execute ':buffer! ' . a:buffer
  set modifiable
  execute ':%d'
  set buftype=nofile
  silent put =a:content
  silent execute '%!python -m json.tool'
  silent execute '%!python -c "import re,sys;sys.stdout.write(re.sub(r\"\\\u[0-9a-f]{4}\", lambda m:m.group().decode(\"unicode_escape\").encode(\"utf-8\"), sys.stdin.read()))"'
  set filetype=json
  set buflisted
  set nomodifiable
endfunction

function! OpenTextContent(content)
  enew!
  silent put =a:content
endfunction

function! GetBufferName(type, identifier)
  return a:type . ':' . a:identifier
endfunction

function! ShowObject(type,...)
  let cword = expand("<cword>")
  let identifier = get(a:, 1, cword)
  let buffer = GetBufferName(a:type, identifier)
  let token = GetToken()

  let url = printf("%s/observer?type=%s&identifier=%s", g:blue_base_url, a:type, identifier)
  let ret = webapi#http#get(url, {}, {'token': token, 'content-type': 'application/json'})
  if ret.status == '404'
    echo a:type . ': ' . identifier . ' NOT FOUND'
    return
  endif
  call OpenObjectContent(ret.content, buffer)
endfunction

function! ShowObjectWithSuggestionType()
  let cword = expand("<cword>")
  let types = GetSuggestTypes(cword)
  
  if len(types) > 1
    let choiceType = AskForSuggestType(types)
  elseif len(types) == 1
    let choiceType = types[0]
  else
    echo 'Suggest object type NOT FOUND'
    return
  endif

  call ShowObject(choiceType, cword)
endfunction

function! ShowIdentifierWithSuggestionType(identifier)
  let cword = a:identifier
  let types = GetSuggestTypes(cword)
  
  if len(types) > 1
    let choiceType = AskForSuggestType(types)
  elseif len(types) == 1
    let choiceType = types[0]
  else
    echo 'Suggest object type NOT FOUND'
    return
  endif

  call ShowObject(choiceType, cword)
endfunction

function! ShowText(type,...)
  let cword = expand("<cword>")
  let identifier = get(a:, 1, cword)

  let url = printf("%s/observer?type=%s&identifier=%s", g:blue_base_url, a:type, identifier)
  let ret = webapi#http#get(url, {}, {'token': g:blue_token })
  if ret.status == '404'
    echo a:type . ': ' . identifier . ' NOT FOUND'
    return
  endif
  call OpenTextContent(ret.content)
endfunction

function! ReloadTypes()
  call LoadTypes()
  echo 'Reload Types Finished!'
endfunction

function! LoadTypes()
  let cword = expand("<cword>")
  let identifier = get(a:, 1, cword)

  let ret = webapi#http#get(g:blue_base_url . '/types', {}, {})
  if ret.status == '404'
    echo 'types NOT FOUND'
    return
  endif
  let g:blueTypes = json_decode(ret.content)
endfunction

function! ShowObjectWithCword(type)
  let identifier = expand("<cword>")
  call ShowObject(type, identifier)
endfunction

function! GetToken()
  return g:blue_token
  #let res = webapi#http#get(g:blue_token_address)
  #let obj = webapi#json#decode(res.content)
  #return obj.GET
endfunction

function! GetSuggestTypes(value)
  let types = []
  for bt in g:blueTypes
    let type = matchstr(a:value, '\v' . bt['identifierRegex'])
    if empty(type)
      continue
    endif
    call add(types, bt['code'])
  endfor

  return types
endfunction

function! AskForSuggestType(types) abort
  echom 'This `List` is a value looks like'
  while 1
    let items = []
    let index = 1
    for type in a:types
      call add(items, index . '.' . type)
      let index += 1
    endfor
  
    let choice = inputlist(items)
    if choice == 0 || choice > len(a:types)
      redraw!
      echohl WarningMsg
      echo 'Please enter a number between 1 and ' . len(a:types)
      echohl None
      continue
    else
      return a:types[choice - 1]
    endif
  endwhile
endfunction

call LoadTypes()

command! -nargs=? Bo :call ShowObjectWithSuggestionType(<args>)
command! -nargs=? Bi :call ShowIdentifierWithSuggestionType(<args>)
command! -nargs=? Brl :call ReloadTypes()
