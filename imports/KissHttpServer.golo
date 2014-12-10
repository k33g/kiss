module kiss

import gololang.concurrent.workers.WorkerEnvironment
import gololang.Async

import java.util.regex.Matcher
import java.util.regex.Pattern

struct bob = { foo }
augment bob {
  function hello = |this| {
    println("hello")
  }
} 

struct uriTemplate = {
    template            # String
  , regex               # Pattern
  , vars                # String[]
  , charCnt             # int

}

# Inspiration
#
# org.springframework.web.util : Class UriTemplate
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
  , message   # not used for the moment
  , exchange
}

augment response {

  function send = |this| {
    this: exchange(): sendResponseHeaders(this: code(), this: content(): length())
    this: exchange(): getResponseBody(): write(this: content(): getBytes())
    this: exchange(): close()  
  }


  function headers = |this| -> this: exchange(): getResponseHeaders()

  function contentType = |this, content_type| {
    this: headers(): set("Content-Type", content_type)
    return this
  }
  function contentType = |this| -> this: headers(): get("Content-Type")

  function json = |this, value| -> this: contentType("application/json"): content(JSON.stringify(value)): send()

  function html = |this, value| -> this: contentType("text/html"): content(value): send()
  function text = |this, value| -> this: contentType("text/plain"): content(value): send()

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

  function redirect = |this, location| {
      this: code(302): content("Redirecting ..."): headers(): set("Location", location)
      this: send()
      return this
  }

  function redirect = |this, location, code| {
      this: code(code): content("Redirecting ..."): headers(): set("Location", location)
      this: content("Redirecting ...")
      this: headers(): set("Location", location)
      this: send()
      return this
  }

  # === Server-Sent Events ===
  # http://www.html5rocks.com/en/tutorials/eventsource/basics/
  function SSEInit = |this| {
    #let responseHeaders = this: exchange(): getResponseHeaders()
    this: headers(): set("Content-Type", "text/event-stream;charset=UTF-8") # ? ;charset=UTF-8
    this: headers(): set("Cache-Control", "no-cache")
    this: headers(): set("Connection", "keep-alive")
    
    this: exchange(): sendResponseHeaders(200, 0)
    this: content(".") # avoid 404, see KissHttpServer.golo
    return this
  }

  function SSEWrite = |this, data| {
    let SSEData = "data:"+ data +"\n\n"
    this: exchange(): getResponseBody(): write(SSEData: getBytes())
    this: exchange(): getResponseBody(): flush()
    return this
  }
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
    return this
  }

  function route = |this, method, routeTemplate, condition, work| {
    let params = UriTemplate(routeTemplate): matchString(this: request(): uri(): toString())
    if this: request(): method(): equals(method)
    and params: size() > 0
    and condition(this: response(), this: request()) {
      this: request(): parameters(params)
      work(this: response(), this: request())
    }
    return this
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
        : send()
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
          : send()
      }

    })

    return this
  } # end of function static



} # end of augment httpExchange


struct httpServer = {
    host
  , port
  , _serverInstance
  , _when404
  , _whenError
  , env
  , application
}

augment httpServer {

  function when404 = |this, workWenSomethingWrong| {
    this: _when404(workWenSomethingWrong)
  }

  function whenError = |this, workWenSomethingWrong| {
    this: _whenError(workWenSomethingWrong)
  }

  function watch = |this, directories, work| { # "/"

    let env = WorkerEnvironment.builder(): withFixedThreadPool()

    let getWatcherWorker = -> env: spawn(|path| {

      while (true) {
        try {
          let watcher = java.nio.file.FileSystems.getDefault(): newWatchService() # WatchService

          path: register(
              watcher
            , java.nio.file.StandardWatchEventKinds.ENTRY_CREATE()
            , java.nio.file.StandardWatchEventKinds.ENTRY_DELETE()
            , java.nio.file.StandardWatchEventKinds.ENTRY_MODIFY()
          )

          let watchKey = watcher: take() # WatchKey

          let events = watchKey: pollEvents()

          if events: size() > 0 {
            work(events)
          }



        } catch (error) {
          println(error: getMessage())
          println(error)
          error: getStackTrace(): asList(): each(|row| {
            println(row: toString())
          })
        }
      }

    }) # end of getWatcherWorker

    directories: each(|directory| {
      println("Watching " + directory + "...")
      getWatcherWorker(): send(java.nio.file.Paths.get(java.io.File("."): getCanonicalPath() + directory))
    })

  }



  function initialize = |this, work| {

    let env = WorkerEnvironment.builder(): withCachedThreadPool()
    #let env = WorkerEnvironment.builder(): withFixedThreadPool()
    #let env = WorkerEnvironment.builder(): withFixedThreadPool(10)

    #let send = |exchange, application| {
    #  exchange: sendResponseHeaders(application: response(): code(), application: response(): content(): length())
    #  exchange: getResponseBody(): write(application: response(): content(): getBytes())
    #  exchange: close() # or flush
    #}
    
    this: env(env) # used with getHttpRequest()

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

    # parameter is a handler (closure) : com.sun.net.httpserver.HttpHandler
    # exchange is com.sun.net.httpserver.HttpExchange
    this: _serverInstance(): createContext("/", |exchange| {

      env: spawn(|exchange| {

        let inputStream = exchange: getRequestBody()
        let inputStreamReader = java.io.InputStreamReader(inputStream)
        let bufferedReader = java.io.BufferedReader(inputStreamReader)
        let stringRead = bufferedReader:readLine()

        let application = httpExchange()
          : response(response("", 200, "", exchange))
          : request(
              request(stringRead, exchange, null)
            )

        application: response(): headers(): set("Content-Type", "application/json") #default json

        try {
          work(application)
        } catch (error) {
          application: response(): code(501)

          if this: _whenError() isnt null {
            this: _whenError()(application: response(), application: request(), error)
            application: response(): send()
          } else {
            application: response(): headers(): set("Content-Type", "text/html")
            application: response(): content(errorReport(error))
            application: response(): send()
          }
          
        } finally {
          # handle 404

          if application: response(): content(): length() is 0 { # TODO: find way to better manage handle of 404
            application: response(): code(404)
            if this: _when404() isnt null { this: _when404()(application: response(), application: request())}
            application: response(): send()
          } 
        }

      }): send(exchange)

    })

    this: _serverInstance(): createContext("/warm/up", |exchange| {

      env: spawn(|exchange| {
        let headers = exchange: getResponseHeaders()
        headers: set("Content-Type", "application/json") #default json

        # : response(response("", 200, "", exchange))

        let params = UriTemplate("/warm/up/{id}"): matchString(exchange: getRequestURI(): toString())
        #println(params)

        let application = httpExchange()
          : response(response(JSON.stringify(map[["message", params: get("id")]]), 200, "OK", exchange))
          : request(
              request("", exchange, null)
            )

        application: response(): send()
        #send(exchange, application)

      }): send(exchange)

    })

    this: _serverInstance(): createContext("/shutdown", |exchange| {
      let headers = exchange: getResponseHeaders()
      headers: set("Content-Type", "application/json") #default json

      let application = httpExchange()
        : response(response(JSON.stringify(map[["message", "bye"]]), 200, "", exchange))
        : request(
            request("", exchange, null)
          )

      application: response(): send()
      #send(exchange, application)

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

  # contentType: "text/plain; charset=utf-8" or "application/json; charset=utf-8"
  # usage:
  # run promise
  #  getHttpRequest("http://localhost:8080/hello", "application/json; charset=utf-8")
  #    : onSet(|responseCode, responseMessage, responseText| { # if success
  #      # foo
  #    })
  #    : onFail(|err| { # if failed
  #      println(err: getMessage())
  #    })

  #  struct response = {
  #      content
  #    , code      # status code
  #    , message   # not used for the moment
  #    , exchange
  #  }


  function getHttpRequest = |this, url, contentType| {

    return promise(): initialize(|resolve, reject| {
      # doing something asynchronous
      this: env(): spawn(|message| {

        try {
          let obj = java.net.URL(url) # URL obj
          let con = obj: openConnection() # HttpURLConnection con (Cast?)
          #optional default is GET
          con: setRequestMethod("GET")
          con: setRequestProperty("Content-Type", contentType)
          #add request header
          con: setRequestProperty("User-Agent", "Mozilla/5.0")

          let responseCode = con: getResponseCode() # int responseCode
          let responseMessage = con: getResponseMessage() # String responseMessage

          let responseText = java.util.Scanner(
            con: getInputStream(), 
            "UTF-8"
          ): useDelimiter("\\A"): next() # String responseText

          # responseCode, responseMessage, responseText
          resolve(response(responseText, responseCode, responseMessage, null))

        } catch(error) {
          reject(error)
        }

      }): send("go")

    })

  }

  function warmUp = |this, howMany| {
    println("Starting warm up ...")
    let counter = Observable(0)
    counter: onChange(|value| {
      #if (value % 2): equals(0) { print(".") }
      if value >= (howMany - 1) {
        println("Warm up ended!")
      }
    })

    howMany: times(|index|->
      this: getHttpRequest("http://"+ this: host() + ":" + this: port() +"/warm/up/" + uuid(), "application/json; charset=utf-8")
        : onSet(|resp| { # if success
          counter: set(index)
          #println(index + " " + resp)
        })
        : onFail(|err| { # if failed
          #println(err: getMessage())
        })
    ) #TODO: count in onSet to know when finished

  }

}

function HttpServer = |host, port, work| ->
  httpServer(): host(host): port(port): initialize(work)


