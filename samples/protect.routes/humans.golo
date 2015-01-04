module humans

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange
import kiss.httpExchange.augmentations

function main = |args| {

  let humans = list[
    map[["_id", uuid()], ["firstName", "Bob"],["lastName", "Morane"]],
    map[["_id", uuid()], ["firstName", "John"],["lastName", "Doe"]],
    map[["_id", uuid()], ["firstName", "Bruce"],["lastName", "Wayne"]],
    map[["_id", uuid()], ["firstName", "Clark"],["lastName", "Kent"]],
    map[["_id", uuid()], ["firstName", "Peter"],["lastName", "Parker"]],
    map[["_id", uuid()], ["firstName", "Jane"],["lastName", "Doe"]]
  ]

  let amIanAdministrator = false

  let isAdmin = |res, req| {
    if amIanAdministrator {
      return true
    } else {
      res: json(message("You're not administrator!!!"))
      return false
    }
  }

  let server = HttpServer("localhost", 8080, |app| {
    # static assets location
    app: static("/public", "index.html")

    app: $get("/humans"
    , |res, req| -> isAdmin(res, req)
    , |res, req| {
      # send all humans
      res: json(humans)
    })

    # app: route("GET", "/allhumans", ...) is similar to app: $get("/humans", ...)
    app: route("GET", "/allhumans"
    , |res, req| -> isAdmin(res, req)
    , |res, req| {
      # send all humans
      res: json(humans)
    })

  })
  
  server: start(">>> http://localhost:"+ server: port() +"/")

  server: watch(["/"], |events| {
      events: each(|event| -> println(event: kind() + " " + event: context()))
      java.lang.System.exit(1) #exit and restart
  })
}