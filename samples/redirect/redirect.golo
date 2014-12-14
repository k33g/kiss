module redirectToSomewhere

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange

function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {

    # redirect to /home
    app: method("GET", |route| -> route: equals("/"), |response, request| ->
      response: redirect("/home", 301)
    )

    # home page
    app: method("GET", |route| -> route: equals("/home"), |response, request| {
      response: html("<h1>this is the Home</h1>")
    })

  })

  server: start(">>> http://localhost:8080/")
}
