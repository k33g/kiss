module main

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange

augment  kiss.httpExchange.types.httpExchange {
  function GET = |this, templateRoute, work| -> this: route("GET", templateRoute, work)
  function POST = |this, templateRoute, work| -> this: route("POST", templateRoute, work)
  # etc. ...
}


function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {
    app: GET("/", |res, req| -> res: html("<h1>Hello World!!!</h1>"))
    app: GET("/hello", |res, req| -> res: json(DynamicObject(): message("hello world!!!")))
    app: GET("/yo", |res, req| -> res: json(DynamicObject(): message("yo")))
    app: GET("/plop", |res, req| -> res: json(DynamicObject(): message("plop")))
  })

  server: start(">>> http://localhost:8080/")

}