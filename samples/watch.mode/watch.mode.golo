module main

import kiss

function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {
    app: route("GET", "/", |res, req| -> res: html("<h1>Hello World!</h1>"))
    app: route("GET", "/hello", |res, req| -> res: json(DynamicObject(): message("hello world!")))
  })

  server: start(">>> http://localhost:8080/")

  server: watch(["/"], |events| {
      events: each(|event| -> println(event: kind() + " " + event: context()))
      java.lang.System.exit(1)
  })

}