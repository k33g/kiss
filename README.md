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
import kiss.request
import kiss.response
import kiss.httpExchange

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
```

##Routing with route template

```coffeescript
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
```

##Static assets

```coffeescript
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
```

##CORS support

```coffeescript
module main

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange

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
import kiss.request
import kiss.response
import kiss.httpExchange

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
import kiss.request
import kiss.response
import kiss.httpExchange

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
import kiss.request
import kiss.response
import kiss.httpExchange

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
augment kiss.httpExchange.types.httpExchange {
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

- `response` structure (`kiss.response.types.response`)
- `request` structure (`kiss.request.types.request`)
- and even with `httpServer` (`kiss.types.httpServer`)

##Syntactic glue to kiss rest methods

This is an augmentation of httpExchange structure

```coffeescript
module main

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange

function main = |args| {


  let server = HttpServer("localhost", 8080, |app| {

    app: static("/public", "index.html")

    app: $get("/hello", |res, req| {
      res: json(DynamicObject()
        : message("Hello World!")
        : number(42)
      )
    })

    app: $post("/humans", |res, req| {
      let user = req: json() # from json, get data from POST request
      user: put("id", uuid(): toString())
      res
        : code(201)
        : json(user) # return json representation of the user with 201 status code
    })

  })

  server: start(">>> http://localhost:8080/")

}
```

And you can use `$put()` and `$delete()` too

##Protect your routes

```coffeescript
module main

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange

function main = |args| {

  let amIanAdministrator = false

  let isAdmin = |res, req| {
    if amIanAdministrator {
      return true
    } else {
      res: json(message("You're not administrator!!!"))
      return false
    }
  }

  let server = HttpServer("localhost", 8080, |app| {
    # static assets location
    app: static("/public", "index.html")

    # the anonymous function is called only id `isAdmin` is true
    # else `message("You're not administrator!!!")` is send to the browser
    app: $get("/humans"
    , |res, req| -> isAdmin(res, req)
    , |res, req| {
      # send all humans
      res: json(humans)
    })

  })
  server: start(">>> http://localhost:8080/")

}
```

##Stream Updates with Server-Sent Events

If you want developp a stream service, you have to write something like this:

```coffeescript
# server side

app: route("GET", "/sse", |res, req| {
  res: SSEInit()
  res: SSEWrite("plop"): SSEWrite(uuid()): SSEWrite(java.util.Date(): toString())        
})
```

and 

```javascript
// browser side

var source = new EventSource('/sse');

source.addEventListener('message', function(e) {
  console.log(e.data);
}, false);

source.addEventListener('open', function(e) {
  // Connection was opened.
  console.log("Connection was opened.")
}, false);

source.addEventListener('error', function(e) {
  if (e.readyState == EventSource.CLOSED) {
    // Connection was closed.
    console.log("Connection was closed.")
  }
}, false);
```

##View helper

View helper is an augmented structure using Golo templating capabilities. You can define a template and pass data to it.
Before compiling the template you can add static resource or load static resource (ie: html file).
You need to import `kiss.views` module.

- Define a view: `let myView = view(): template("your_string_template")`
- add static resource: `myView: addResource(resourceId, resourceValue)`
- load static resource: `myView: loadResource(resourceId, pathOfTheResourceAndName)`
- use static resource inside the template: `<%= rsrc: get(resourceId) %>`
- send dynamic data to the view: `myView: data(yourData)`
- render the view: `myView: render()` (return a string)
- use dynamic data inside the template: ie, if `yourData == list["Bob"]`, you have to use the `data` keyword inside the template, and you can use all methods attached to the data type: `<%= data: get(0) %>`

###Sample

```coffeescript
module myview

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange
import kiss.http
import kiss.views


function HomeView = -> view(): template("""
  <h1><%= rsrc: get("title") %></h1>
  <hr>
  <h2><%= data: get(0) %></h2>
  <h2><%= data: get(1) %></h2>
  <hr>
  <%= rsrc: get("footer") %>
"""
)

function main = |args| {

  # compile template
  let homeView = HomeView()
    : addResource("title", "Hello World From Kiss! with Love <3") # add once (static resource)
    : loadResource("footer", "/footer.html") # add once (pre load static resource)


  let server = HttpServer("localhost", 8080, |app| {

    app: $get("/", |res, req| {
      res: html(
        homeView: data(list["Bob Morane", "John Doe"]): render()
      )
    })

  })

  server: start(">>> http://localhost:"+ server: port() +"/")

}
```

##BDD with Kiss `wip`

```coffeescript
module my.app

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange
import kiss.http          #<- you need this to make http request
import kiss.tests         #<- this is the bdd dsl

function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {

    app: $get("/hello"
    , |res, req| {
      res: json(message("hello"))
    })

    app: $get("/hi"
    , |res, req| {
      res: json(message("hi"))
    })

  })

  server: start(">>> http://localhost:"+ server: port() +"/")

  #--------------------------------
  # run bdd tests
  #--------------------------------

  describe("Testing welcome routes", {

    it("We can call /hello", {

      getAndWaitHttpRequest("http://localhost:"+ server: port() + "/hello", "application/json;charset=UTF-8")
        : onSet(|result| { # if success

            expect(result: code()): toEqual(200)
            expect(result: message()): toEqual("OK")
            expect(result: text()): toEqual(JSON.stringify(message("hello")))

        })
        : onFail(|err| { # if failed
            println(err)
            expect(true): toEqual(false)
        })
    })

    it("We can call /hi", {

      getAndWaitHttpRequest("http://localhost:"+ server: port() + "/hi", "application/json;charset=UTF-8")
        : onSet(|result| { # if success

            expect(result: code()): toEqual(200)
            expect(result: message()): toEqual("OK")
            expect(result: text()): toEqual(JSON.stringify(message("hi")))

        })
        : onFail(|err| { # if failed
            println(err)
            expect(true): toEqual(false)
        })
    })

  })

}
```

###Add your own matcher

You can easily add matchers to the test module thanks to the Golo named augmentation:

```coffeescript
# my little matcher
augmentation halfMatcher = {
	function toBeHalf = |this, expectedValue| {
		require(
			this: actualValue(): equals(expectedValue/2),
			this: actualValue() + " isn't half " + expectedValue
		)
		println(" OK: " + this: actualValue() + " is half " + expectedValue)
		return this # you can chain matchers
	}
}
```

You have to "graft" the new matcher to the others like that:

```coffeescript
augment kiss.tests.types.matchers with halfMatcher
```

And you can use it like that:

```coffeescript
expect(4): toBeHalf(8): toBeInteger()
```

##Warm up Kiss server

Sometimes, it could be interesting to warm up the serveur:

```coffeescript
  server: start(">>> http://localhost:8080/")
  server: warmUp(20000) # number of loops as parameter, 10000 seems to be a good number
```




#TODO:

- MongoDb Support
- Redis (Jedis) Support
- Explain how to "mavenize" a kiss project
- set cookie with max-age
- https
- documentation
- websockets
- provide performances tests
- improve SSE (json and multilines)
- add samples with MongoDb and Redis

