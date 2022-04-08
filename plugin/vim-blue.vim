function! OpenObjectContent(content, buffer)
  call bufadd(a:buffer)
  execute ':buffer! ' . a:buffer

  set modifiable
  execute ':%d'
  set buftype=nofile
  silent put =a:content
  slient execute '%!python -m json.tool'
  slient execute '%!python -c "import re,sys;sys.stdout.write(re.sub(r\"\\\u[0-9a-f]{4}\", lambda m:m.group().decode(\"unicode_escape\").encode(\"utf-8\"), sys.stdin.read()))"'
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

  let url = printf("%s?type=%s&identifier=%s", g:blue_base_url, a:type, identifier)
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

function! ShowText(type,...)
  let cword = expand("<cword>")
  let identifier = get(a:, 1, cword)

  let url = printf("%s?type=%s&identifier=%s", g:blue_base_url, a:type, identifier)
  let ret = webapi#http#get(url, {}, {'token': g:blue_token, 'content-type': 'application/json'})
  if ret.status == '404'
    echo a:type . ': ' . identifier . ' NOT FOUND'
    return
  endif
  call OpenTextContent(ret.content)
endfunction

function! ShowObjectWithCword(type)
  let identifier = expand("<cword>")
  call ShowObject(type, identifier)
endfunction

function! GetToken()
  let res = webapi#http#get(g:blue_token_address)
  let obj = webapi#json#decode(res.content)

  return obj.GET
endfunction

function! GetSuggestTypes(value)
  let regs = { 'order': '^[0-9]{14}$', 'plan': '^[0-9]{14}$', 'trace': '^[0-9]{14}$', 'customer': '^[0-9]{19}$', 'staff': '^[0-9]{19}$', 'org': '^XL[0-9]{6}$', 'task': '^[0-9]{19}$', 'taking-task-order': '^[0-9]{14}$', 'sending-task-order': '^[0-9]{14}$' }
  let types = []
  for key in keys(regs)
    let type = matchstr(a:value, '\v' . regs[key])
    if empty(type)
      continue
    endif
    call add(types, key)
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


command! -nargs=? Border :call ShowObject("order", <args>)
command! -nargs=? Bplan :call ShowObject('plan', <args>)
command! -nargs=? Btrace :call ShowObject('trace', <args>)
command! -nargs=? Bstaff :call ShowObject('staff', <args>)
command! -nargs=? Bcustomer :call ShowObject('customer', <args>)
command! -nargs=? Borg :call ShowObject('org', <args>)
command! -nargs=? Bjgorder :call ShowObject('jg-order', <args>)
command! -nargs=? Bagencyorder :call ShowObject('agency-order', <args>)
command! -nargs=? Bcompany :call ShowObject('company', <args>)
command! -nargs=? Blog :call ShowText('log', <args>)
command! -nargs=? Bo :call ShowObjectWithSuggestionType(<args>)
