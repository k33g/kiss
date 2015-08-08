module kiss

import gololang.concurrent.workers.WorkerEnvironment
import gololang.Async

import kiss.contentTypes
import kiss.uriTemplate
import kiss.request
import kiss.response
import kiss.httpExchange

struct messageStructure = {
  message
}
function message = |msg| -> messageStructure(msg)

augment java.net.URI {
  function parts = |this| -> this: toString(): split("/"): asList(): filter(|part| -> not part: equals(""))
}

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
          : response(response("", 200, null, exchange))
          : request(
              request(stringRead, exchange, null)
            )

        application: response(): headers(): set("Content-Type", "application/json") #default json

        #--- sandbox ---
        this: application(application)

        try {
          work(application)

        } catch (error) {
          application: response(): code(501): message("KO")

          if this: _whenError() isnt null {
            this: _whenError()(application: response(), application: request(), error)
            #application: response(): send()
          } else {
            application: response(): headers(): set("Content-Type", "text/html")
            application: response(): content(errorReport(error))
            application: response(): send()
          }
        } finally {

          # handle 404
          # if application: response(): message() is null and application: response(): content(): length() is 0  {
          if application: response(): message() is null {
            application: response(): code(404)
            application: response(): headers(): set("Content-Type", "text/html")
            if this: _when404() isnt null {
              this: _when404()(application: response(), application: request())
            } else {
              application: response(): content("<h1>Error 404</h1>")
              application: response(): send()
            }
            #application: response(): send()
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
          JSON.parse(JSON.stringify(resp))
          counter: set(index)
        })
        : onFail(|err| { # if failed
        })
    ) 

  }

}

function HttpServer = |host, port, work| ->
  httpServer(): host(host): port(port): initialize(work)


