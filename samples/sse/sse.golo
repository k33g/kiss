module sse

import kiss


function main = |args| {


  let server = HttpServer("localhost", 8080, |app| {

    # static assets location
    app: static("/public", "index.html")

    app: route("GET", "/sse", |res, req| {
      res: SSEInit()
      500: times(|index| {
        res: SSEWrite(index + " " + java.util.Date()): SSEWrite(uuid())
      })
    })

  })
  
  server: start(">>> http://localhost:8080/")
  
}