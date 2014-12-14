Kiss
====

####Fast, unopinionated, minimalist web framework for [Golo](http://golo-lang.org/)

<br>
###Install

    git clone  https://github.com/k33g/kiss.git project_name

<br>
###Run it

    golo golo --files imports/*.golo main.golo

    # or;
    ./kiss.dev.sh

<br>
###Basic routing

    module basic.routing

    import kiss
    import kiss.request
    import kiss.response
    import kiss.httpExchange

    function main = |args| {

      let server = HttpServer("localhost", 8080, |app| {

        # respond with "Hello World!" on the homepage
        app: method("GET", |route|-> route: equals("/"), |response, request| ->
          response : html("<h1>Hello World!</h1>")
        )

        # accept POST request on the homepage
        app: method("POST", |route|-> route: equals("/"), |response, request| ->
          response: html("<h1>Got a POST request</h1>")
        )

        # accept GET request at /users/some/thing
        app: method("GET", |route|-> route: startsWith("/users/"), |response, request| ->
          response : json(DynamicObject()
            : message("Got a GET request at /users/some/thing")
            : uriParts(request: uri(): parts()) # return ["users", "some", "thing"]
          )
        )

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

<br>
###Routing with route template

    module templates.routing

    import kiss
    import kiss.request
    import kiss.response
    import kiss.httpExchange

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

<br>
###Static assets

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

<br>