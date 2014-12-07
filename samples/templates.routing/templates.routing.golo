module templates.routing

import kiss

function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {

    # accept GET request at /users/some/thing
    app: route("GET", "/users/{some}/{thing}", |response, request| ->
      response : json(DynamicObject()
        : message("Got a GET request at /users/some/thing")
        : some(request: params("some"))
        : thing(request: params("thing"))
      )
    )

  })

  server: start(">>> http://localhost:8080/")
}
