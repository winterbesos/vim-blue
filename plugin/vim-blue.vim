function! OpenContent(content)
  enew!
  silent put =a:content
  execute '%!python -m json.tool'
  execute '%!python -c "import re,sys;sys.stdout.write(re.sub(r\"\\\u[0-9a-f]{4}\", lambda m:m.group().decode(\"unicode_escape\").encode(\"utf-8\"), sys.stdin.read()))"'
  set filetype=json
endfunction

function! ShowObject(type,...)
  let cword = expand("<cword>")
  let identifier = get(a:, 1, cword)

  let url = printf("%s?type=%s&identifier=%s", g:blue_base_url, a:type, identifier)
  let ret = webapi#http#get(url, {}, {'token': g:blue_token, 'content-type': 'application/json'})
  if ret.status == '404'
    echo a:type . ': ' . identifier . ' NOT FOUND'
    return
  endif
  call OpenContent(ret.content)
endfunction

function! ShowObjectWithCword(type)
  let identifier = expand("<cword>")
  call ShowObject(type, identifier)
endfunction


command -nargs=? Border :call ShowObject("order", <args>)
command -nargs=? Bplan :call ShowObject('plan', <args>)
command -nargs=? Bstaff :call ShowObject('staff', <args>)
command -nargs=? Bcustomer :call ShowObject('customer', <args>)
command -nargs=? Borg :call ShowObject('org', <args>)
command -nargs=? Bjgorder :call ShowObject('jg-order', <args>)
command -nargs=? Bagencyorder :call ShowObject('agency-order', <args>)
command -nargs=? Bcompany :call ShowObject('company', <args>)
