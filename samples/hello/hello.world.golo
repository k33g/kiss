module hello.world

import kiss

function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {

    app: all(|response, request| -> response: html("<h1>Hello World!</h1>"))

  })

  server: start(">>> http://localhost:8080/")
}