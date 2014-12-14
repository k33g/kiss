module basic.routing

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange

function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {

    # respond with "Hello World!" on the homepage
    app: method("GET", |route| -> route: equals("/"), |response, request| ->
      response : html("<h1>Hello World!</h1>")
    )

    # accept POST request on the homepage
    app: method("POST", |route| -> route: equals("/"), |response, request| {
      println(request: json()) # display POST data
      response: code(201)
      response: html("<h1>Got a POST request</h1>")
    })

    # accept GET request at /users/some/thing
    app: method("GET", |route|-> route: startsWith("/users/"), |response, request| {
      response : json(DynamicObject()
        : message("Got a GET request at /users/some/thing")
        : uriParts(request: uri(): parts()) # return ["users", "some", "thing"]
      )
    })

    # accept PUT request at /users
    app: method("PUT", |route|-> route: equals("/users"), |response, request| ->
      response: html("Got a PUT request at /users")
    )

    # accept DELETE request at /users
    app: method("DELETE", |route|-> route: equals("/users"), |response, request| ->
      response: html("Got a DELETE request at /users")
    )

  })

  server: start(">>> http://localhost:8080/")
}
