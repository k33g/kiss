module main

import kiss

function main = |args| {


  let server = HttpServer("localhost", 8080, |app| {
    #app: all(|res, req| { println("Hello") })

    app: static("/public", "index.html")

    app: route("GET", "/hello", |res, req| {
      res: json(DynamicObject()
        : message("Hello World!")
        : number(42)
      )
    })

  })

  server: start(">>> http://localhost:8080/")

  server: watch(["/", "/public", "/public/js"], |events| {
      events: each(|event| -> println(event: kind() + " " + event: context()))
      java.lang.System.exit(1)
  })


}