module kiss.contentTypes

# module level state
let contentTypes = map[
    ["htm","text/html;charset=UTF-8"]
  , ["html","text/html;charset=UTF-8"]
  , ["md","text/html;charset=UTF-8"]
  , ["asciidoc","text/html;charset=UTF-8"]
  , ["adoc","text/html;charset=UTF-8"]
  , ["css","text/css;charset=UTF-8"]
  , ["less","text/css;charset=UTF-8"]
  , ["js","application/javascript;charset=UTF-8"]
  , ["coffee","application/javascript;charset=UTF-8"]
  , ["ts","application/javascript;charset=UTF-8"]
  , ["dart","application/javascript;charset=UTF-8"]
  , ["json","application/json;charset=UTF-8"]
  , ["ico","image/x-ico"]
  , ["gif","image/gif"]
  , ["jpeg","image/jpeg"]
  , ["jpg","image/jpeg"]
  , ["png","image/png"]
  , ["svg","image/svg+xml"]
  , ["eot","application/vnd.ms-fontobject"]
  , ["ttf","application/x-font-ttf"]
  , ["woff","application/x-font-woff"]
  , ["zip","application/zip"]
  , ["gzip","application/gzip"]
  , ["pdf","application/pdf"]
  , ["xml","application/xml;charset=UTF-8"]
  , ["txt","text/plain;charset=UTF-8"]
]

function getContentTypes = -> contentTypes

