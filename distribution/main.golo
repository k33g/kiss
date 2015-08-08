module main

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange

function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {
    app: static("/public", "index.html")
  })

  server: start(">>> http://localhost:8080/")
}