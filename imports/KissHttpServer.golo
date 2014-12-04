module kiss

import gololang.concurrent.workers.WorkerEnvironment

# Inspiration
#
# org.springframework.web.util : Class UriTemplate

import java.util.regex.Matcher
import java.util.regex.Pattern

struct uriTemplate = {
    template            # String
  , regex               # Pattern
  , vars                # String[]
  , charCnt             # int

}

augment uriTemplate {
  # Determine if uri is matched by this uri template and return a map of variable
  # values if it does.
  function matchString = |this, uri| { # string / return map  of variable values (or null, if no match, or empty if no vars)
    let values = map[] # Map<String, String>

    # if (uri != null && uri.length() != 0)
    if not (uri is null)  {
      if not (uri: length(): equals(0)) {
        let m = this: regex(): matcher(uri) # Matcher

        if m: matches() {
          values: put(m: groupCount(), 1.0_F)

          for (var i = 0, i < m: groupCount(), i = i +1) {
            var name = this: vars(): get(i)
            var value = m: group(i + 1)
            var existingValue = values: get(name)
            # if (existingValue != null && !existingValue.equals(value))
            if not (existingValue is null) {
              if not (existingValue: equals(value)) {
                return null
              }
            }
            values: put(this: vars(): get(i), value)
          }
        }
      }
    }
    return values
  }
}

function UriTemplate = |template| { # string

  # === constructor ===

  # VALID_URI           # Pattern
  # VARIABLE            # Pattern
  # VARIABLE_REGEX      # String

  #let VALID_URI = Pattern.compile("^/(([\\w\\-]+|\\{([a-zA-Z][\\w]*)\\})(;*)/?)+(\\.\\w+$)?|^/$")
  let VARIABLE = Pattern.compile("\\{([a-zA-Z]\\w*)\\}")
  let VARIABLE_REGEX = "(.*?)"

  #ensure template is syntactically correct
  #println(VALID_URI: matcher(template))

  # convert uri template into equivalent regular expression
  # and extract variable names
  let templateRegex = java.lang.StringBuilder()         # StringBuilder
  let names = list[]                                    # new ArrayList<String>() / List<String>
  var charCnt = 0                                       # int
  var start = 0                                         # int
  var end = 0                                           # int
  let matcher = VARIABLE: matcher(template)             # Matcher

  # Helper for constructing regular expression (escaping regex chars where necessary)
  let appendTemplate = |template, start, end, regex| { # params : String, int, int, StringBuilder / return int
    for (var i = start, i < end, i = i + 1) {
      let c = template: charAt(i)

      if not "(.?)": indexOf(c:toString()): equals(-1) {
        regex: append("\\")
      }
      regex: append(c)
    }
    return end - start
  }

  while matcher: find() {
    end = matcher: start()
    charCnt = charCnt +  appendTemplate(template, start, end, templateRegex)
    templateRegex: append(VARIABLE_REGEX)
    let name = matcher: group(1)
    names: add(name)
    start = matcher: end()
  }
  charCnt = charCnt + appendTemplate(template, start, template: length(), templateRegex)

  # initialize
  let strArray = java.lang.reflect.Array.newInstance(java.lang.String.class, names: size())

  let utiTpl = uriTemplate()
    : template(template)
    : charCnt(charCnt)
    : regex(Pattern.compile(templateRegex: toString()))
    : vars(strArray)

  names: toArray(utiTpl: vars())

  return utiTpl

}


augment java.net.URI {
  function parts = |this| -> this: toString(): split("/"): asList(): filter(|part| -> not part: equals(""))
}

# module level state
let contenTypes = map[
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

function getContentTypes = -> contenTypes

struct httpExchange = {
    response
  , request
}

struct request = {
    data
  , exchange
  , parameters
}

augment request {

  function params = |this, key| -> this: parameters(): get(key)

  function method = |this| -> this: exchange(): getRequestMethod()
  function uri = |this| -> this: exchange(): getRequestURI()
  function headers = |this| -> this: exchange(): getRequestHeaders()

  function json = |this| -> JSON.parse(this: data() orIfNull "{}")

  function splitRoute = |this| -> this: uri(): toString(): split("/"): asList(): filter(|part| -> not part:equals(""))
  # access request cookie by name
  function cookie = |this, name| {
    var cookie = null
    let cookiesParts = this: headers(): get("Cookie"): toString(): split(name + "=")
    if cookiesParts: length() > 1 { cookie = cookiesParts: get(1): split(";"): get(0): split("]"): get(0) }
    return cookie
  }
  # get map of all cookies
  function cookies = |this| {
    let cookies = map[]
    let cookiesString = this: headers(): get("Cookie"): toString()
    let cookiesList = cookiesString: substring(1, cookiesString: length() - 1): split(";"): asList()
    cookiesList: each(|cookie| {
      let cookieParts = cookie: split("=")
      let name = cookieParts: get(0)
      let value = cookieParts: get(1)
      cookies: put(name, value)
    })
    return cookies
  }
}

struct response = {
    content
  , code      # status code
  , exchange
}

augment response {
  function headers = |this| -> this: exchange(): getResponseHeaders()

  function contentType = |this, content_type| {
    this: headers(): set("Content-Type", content_type)
    return this
  }
  function contentType = |this| -> this: headers(): get("Content-Type")
  function json = |this, value| -> this: content(JSON.stringify(value))

  function allowCORS = |this, origin, methods, headers| {
    this: headers(): set("Access-Control-Allow-Origin", origin)
    this: headers(): set("Access-Control-Request-Method", methods)
    this: headers(): set("Access-Control-Allow-Headers", headers)
  }
  # set cookie with a value
  function cookie = |this, name, value| {
    this: headers(): add("Set-Cookie", name + "=" + value + ";")
    return this
  }
  # remove cookie
  function removeCookie = |this, name| {
    this: headers(): add("Set-Cookie", String.format("%s=; Expires=Thu, 01 Jan 1970 00:00:00 GMT", name + "=" + null))
    return this
  }

  # === Server-Sent Events ===
  # TODO
}


augment httpExchange {

  function all = |this, work| -> work(this: response(), this: request())

  # app: route("GET", "/hello/{name}/{home}", |res, req| -> println(req: params()))
  function route = |this, method, routeTemplate, work| {
    let params = UriTemplate(routeTemplate): matchString(this: request(): uri(): toString())
    if this: request(): method(): equals(method)
    and params: size() > 0 {
      this: request(): parameters(params)
      work(this: response(), this: request())
    }
  }

  function route = |this, method, routeTemplate, condition, work| {
    let params = UriTemplate(routeTemplate): matchString(this: request(): uri(): toString())
    if this: request(): method(): equals(method)
    and params: size() > 0
    and condition(this: response(), this: request()) {
      this: request(): parameters(params)
      work(this: response(), this: request())
    }
  }

  function method = |this, method, work| {
    if this: request(): method(): equals(method) {
      work(this: response(), this: request())
    }
    return this
  }

  function method = |this, method, routeCondition, work| {
    if this: request(): method(): equals(method)
    and routeCondition(this: request(): uri(): toString()) {
      work(this: response(), this: request())
    }
    return this
  }

  function method = |this, method, routeCondition, condition, work| {

    if this: request(): method(): equals(method)
    and routeCondition(this: request(): uri(): toString())
    and condition(this: response(), this: request()) {
      work(this: response(), this: request())
    }
    return this
  }


  # getContentTypes()
  function contentTypeOfFile  = |this, path| ->
    contenTypes
      : get(path: substring(path: lastIndexOf(".") + 1))
      orIfNull "text/plain;charset=UTF-8"

  function static = |this, staticAssetsDirectory, defaultPage| {
    # Home
    this: method("GET", |route| -> route: equals("/"), |res, req| {
      let path = currentDir() + staticAssetsDirectory + req: uri(): toString() + defaultPage
      res
        : contentType("text/html")
        : content(fileToText(path, "UTF-8"))
    })

    # Serve assets
    this: method("GET", |route| -> not route: equals("/"), |res, req| {

      let path = currentDir() + staticAssetsDirectory + req: uri(): toString()

      if fileExists(java.io.File(path)) {
        let contentTypeOfAsset = this: contentTypeOfFile(path)
        let content = fileToText(path, "UTF-8")
        res
          : contentType(contentTypeOfAsset)
          : content(content)
      }

    })

    return this
  } # end of function static

} # end of augment httpExchange


struct httpServer = {
    host
  , port
  , _serverInstance
}

augment httpServer {
  function initialize = |this, work| {

    let env = WorkerEnvironment.builder(): withCachedThreadPool()
    #let env = WorkerEnvironment.builder(): withFixedThreadPool()
    #let env = WorkerEnvironment.builder(): withFixedThreadPool(10)

    let send = |exchange, application| {
      exchange: sendResponseHeaders(application: response(): code(), application: response(): content(): length())
      exchange: getResponseBody(): write(application: response(): content(): getBytes())
      exchange: close()
    }

    let errorReport = |error| {
      let stackTrace = list[]

      stackTrace: add(
        "<h1 style='color:black; font-family:Consolas,monospace,serif;'>Error: "
        + error: getMessage()
        + "</h1><hr>"
      )

      error: getStackTrace(): asList(): each(|row| {
        var stringRow = row: toString()
        if stringRow: contains(".golo:") is true {
          stringRow = "<span style='color:red; font-family:Consolas,monospace,serif;'><b>" + stringRow + "</b></span>"
        } else {
          stringRow = "<span style='color:grey; font-family:Consolas,monospace,serif;'>" + stringRow + "</span>"
        }
        stackTrace: add(stringRow)
      })

      # display errors to the console
      println(error: getMessage())
      error: getStackTrace(): asList(): each(|row| { println(row) })

      # send error to the browser
      return stackTrace: join("<br>")
    }

    this: _serverInstance(com.sun.net.httpserver.HttpServer.create(
      java.net.InetSocketAddress(this: host(), this: port()), 0
    ))

    this: _serverInstance(): createContext("/", |exchange| {

      env: spawn(|exchange| {

        let inputStream = exchange: getRequestBody()
        let inputStreamReader = java.io.InputStreamReader(inputStream)
        let bufferedReader = java.io.BufferedReader(inputStreamReader)
        let stringRead = bufferedReader:readLine()

        let application = httpExchange()
          : response(response("", 200, exchange))
          : request(
              request(stringRead, exchange, null)
            )

        application: response(): headers(): set("Content-Type", "application/json") #default json

        try {
          work(application)
        } catch (error) {

          application: response(): headers(): set("Content-Type", "text/html")
          application: response(): content(errorReport(error))
        }

        send(exchange, application)
        #if message:equals("kill") {env: shutdown()}
      }): send(exchange)

    })

    this: _serverInstance(): createContext("/shutdown", |exchange| {
      let headers = exchange: getResponseHeaders()
      headers: set("Content-Type", "application/json") #default json

      let application = httpExchange()
        : response(response(JSON.stringify(map[["message", "bye"]]), headers, 200, exchange))
        : request(
            request("", exchange, null)
          )

      send(exchange, application)

      this: _serverInstance(): stop(5)
      env: shutdown()
    })
    return this
  }
  function start = |this| {
    this: _serverInstance(): start()
  }
  function start = |this, message| {
    this: _serverInstance(): start()
    println(message)
  }
  function stop = |this| {
    this: _serverInstance(): stop(5)
  }
  function stop = |this, sec| {
    this: _serverInstance(): stop(sec)
  }
}

function HttpServer = |host, port, work| ->
  httpServer(): host(host): port(port): initialize(work)


