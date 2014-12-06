module notfoundAndErrors

import kiss

function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {

    # respond with "Hello World!" on the homepage
    app: method("GET", |route| -> route: equals("/"), |response, request| ->
      response : html("<h1>Hello World!</h1>")
    )

    # generate html report error
    app: method("GET", |route| -> route: equals("/generror"), |res, req| {
      let division = 5 / 0
      res: content("ouch")
    })

  })

  server: whenError(|response, request, error| {
    response : html("<h1>Error!!!</h1><h2>" + error: getMessage() + "</h2>")
  })

  server: when404(|response, request| {
    response : html("<h1>404!!!</h1>")
  })

  server: start(">>> http://localhost:8080/")
}
