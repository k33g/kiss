Kiss
====

Fast, unopinionated, minimalist web framework for [Golo](http://golo-lang.org/) 

##Install

    git clone  https://github.com/k33g/kiss.git project_name

###Prerequisites

You have to install [Golo](http://golo-lang.org/). Golo is a "Java jar" (Only Java 7 or 8), so you've just have to declare it in your path. Something like that:

    GOLO_HOME=/path_to_golo_directory
    export GOLO_HOME
    export PATH=$PATH:$GOLO_HOME/bin

##Run it

    golo golo --files imports/*.golo main.golo

**Remark**: `main.golo` is you application file and you need `KissHttpServer.golo` (located in `imports` directory).

##Hello world example

```coffeescript
module hello.world

import kiss

function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {

    app: all(|response, request| ->
      response
        : contentType("text/html")
        : content("<h1>Hello World!</h1>")
    )

  })

  server: start(">>> http://localhost:8080/")
}
```

##Basic routing

```coffeescript
module basic.routing

import kiss

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
```

##Routing with route template

```coffeescript
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
```

##Static assets

```coffeescript
module main

import kiss

function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {

    app: static("/public", "index.html")

  })

  server: start(">>> http://localhost:8080/")

}
```

##CORS support

```coffeescript
module main

import kiss

function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {

    # CORS support
    app: method("GET", |route| -> route: equals("/cors/humans"), |res, req| {
      res: allowCORS("*", "*", "*")
      res: json(DynamicObject(): message("all humans"))
    })

  })

  server: start(">>> http://localhost:8080/")

}
```

##Cookies support

```coffeescript
module cookies

import kiss

function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {

    # static assets location
    app: static("/public", "index.html")

    # cookies management

    app: method("GET", |route| -> route: equals("/setcookie"), |res, req| {
      let myUuid = uuid()
      res: cookie("bob", myUuid)
      res: json(DynamicObject(): newCookie(myUuid))
    })

    app: method("GET", |route| -> route: equals("/getcookie"), |res, req| {
      res: json(DynamicObject(): cookie(req: cookie("bob")))
    })

    app: method("GET", |route| -> route: equals("/deletecookie"), |res, req| {
      res: removeCookie("bob")
      res: json(DynamicObject(): deletedCookie(req: cookie("bob")))
    })

    app: method("GET", |route| -> route: equals("/getallcookies"), |res, req| {
      res: json(DynamicObject(): cookies(req: cookies()))
    })

  })

  server: start(">>> http://localhost:8080/")

}
```

##Handle 404

```coffeescript
module notfoundAndErrors

import kiss

function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {

    # respond with "Hello World!" on the homepage
    app: method("GET", |route| -> route: equals("/"), |response, request| ->
      response : html("<h1>Hello World!</h1>")
    )

  })

  server: when404(|response, request| {
    response : html("<h1>404!!!</h1>")
  })

  server: start(">>> http://localhost:8080/")
}
```

##Handle Errors

```coffeescript
module notfoundAndErrors

import kiss

function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {

    # respond with "Hello World!" on the homepage
    app: method("GET", |route| -> route: equals("/"), |response, request| ->
      response : html("<h1>Hello World!</h1>")
    )

    # generate html report error
    app: method("GET", |route| -> route: equals("/generror"), |response, request| {
      let division = 5 / 0
      response: content("ouch")
    })

  })

  server: whenError(|response, request, error| {
    response : html("<h1>Error!!!</h1><h2>" + error: getMessage() + "</h2>")
  })

  server: start(">>> http://localhost:8080/")
}
```

**Remark**: if you don't use `server: whenError(...)`, Kiss displays error message and stacktrace in the browser.


##Redirection

```coffeescript
# redirect to /home
app: method("GET", |route| -> route: equals("/"), |response, request| ->
  response: redirect("/home", 301)
  # or response: redirect("/home"), default status code is 302
)

# home page
app: method("GET", |route| -> route: equals("/home"), |response, request| {
  response: html("<h1>this is the Home</h1>")
})
```

##Use external jar(s)

You have just to put your jars in the jars directory. Then you can run your project as this:

    golo golo --classpath jars/*.jar --files imports/*.golo main.golo

##Watching mode

Kiss comes with a watching mode, which is useful to detect files change. For example, you can use it to exit and relaunch Kiss to take changes in account or run some tasks when assets change.

**Example:**

Add this to your main code (see `main.golo` or `/samples/watch.mode/watch.mode.golo`):

```coffeescript
server: watch(["/", "/public", "/public/js"], |events| {
    events: each(|event| -> println(event: kind() + " " + event: context()))
    java.lang.System.exit(1)
})
```

And run your project with a `sh` script like that:

    #!/bin/sh
    #

    RC=1
    #trap "echo CTRL-C was pressed" 2
    trap "exit 1" 2
    while [ $RC -ne 0 ] ; do
       golo golo --classpath jars/*.jar --files imports/*.golo main.golo
       RC=$?
    done

*See `kiss.dev.sh`*

##Pimp my Kiss framework ... Or how to augment power of Kiss

There is a nice ability with Golo, you can augment Java classes and Golo structures (see this [http://golo-lang.org/documentation/next/index.html#_augmenting_classes](http://golo-lang.org/documentation/next/index.html#_augmenting_classes)). And of course you can do that with **Kiss**:

When you write this:

```coffeescript
let server = HttpServer("localhost", 8080, |app| {

  app: route("GET", "/hello", |res, req| -> res: html("<h1>Hello!</h1>""))

})
```

The `app` parameter is an instance of `kiss.httpExchange`, so if you don't like the grammar of **Kiss** to define routes, you can do something like that:

```coffeescript
augment kiss.types.httpExchange {
  function GET = |this, templateRoute, work| -> this: route("GET", templateRoute, work)
  function POST = |this, templateRoute, work| -> this: route("POST", templateRoute, work)
  # etc. ...
} 
```

and now, you can use it, like that:

```coffeescript
  app: GET("/hello", |res, req| -> res: html("<h1>Hello!</h1>"))

  app: POST("/hi", |res, req| { 
    # foo 
  })
```

**And, you can do that with**:

- `response` structure (`kiss.types.response`)
- `request` structure (`kiss.types.request`)
- and even with `httpServer` (`kiss.types.httpServer`)

#TODO:

- Explain how to "mavenize" a kiss project
- set cookie with max-age
- https
- documentation
- SSE
