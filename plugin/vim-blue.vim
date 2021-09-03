function! OpenContent(content)
  enew!
  silent put =a:content
  execute '%!python -m json.tool'
  execute '%!python -c "import re,sys;sys.stdout.write(re.sub(r\"\\\u[0-9a-f]{4}\", lambda m:m.group().decode(\"unicode_escape\").encode(\"utf-8\"), sys.stdin.read()))"'
  set filetype=json
endfunction

function! ShowObject(type)
  let identifier = expand("<cword>")
  let url = printf("%s?type=%s&identifier=%s", g:blue_base_url, a:type, identifier)
  let ret = webapi#http#get(url, {}, {'token': g:blue_token, 'content-type': 'application/json'})
  if ret.status == '404'
    echo a:type . ': ' . identifier . ' NOT FOUND'
    return
  endif
  call OpenContent(ret.content)
endfunction
