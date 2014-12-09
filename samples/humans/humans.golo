module humans

import kiss

function main = |args| {


  let server = HttpServer("localhost", 8080, |app| {

    # hello is displayed at each request
    #app: all(|res, req| { println("Hello") })

    # static assets location
    app: static("/public", "index.html")

    # GET
    # ie: http://localhost:8080/humans/bob/morane
    # return json object to the browser : {"last":"morane","parts":["humans","bob","morane"]}
    app: method("GET", |route| -> route: startsWith("/humans/"), |res, req| {
      res: json(DynamicObject()
        : last(req: uri(): parts(): last()) # = "morane"
        : parts(req: uri(): parts()) # = ["humans", "bob", "morane"]
      )
    })

    # experimental : route template
    # GET
    # ie: http://localhost:8080/characters/bob/morane
    # return json object to the browser : {"firstName":"bob","lastName":"morane"}
    app: route("GET", "/characters/{firstname}/{lastname}", |res, req| {
      res: json(DynamicObject()
        : firstName(req: params("firstname"))
        : lastName(req: params("lastname"))
      )
    })

    # GET
    # ie: http://localhost:8080/humans
    # return an array of json objects to the browser
    app: method("GET", |route| -> route: equals("/humans"), |res, req| {
      res: json([
        map[["id", uuid()], ["firstName", "Bob"],["lastName", "Morane"]],
        map[["id", uuid()], ["firstName", "John"],["lastName", "Doe"]],
        map[["id", uuid()], ["firstName", "Jane"],["lastName", "Doe"]]
      ])
    })

    # CORS support
    app: method("GET", |route| -> route: equals("/cors/humans"), |res, req| {
      res: allowCORS("*", "*", "*")
      res: json(DynamicObject(): message("all humans"))
    })

    # POST
    app: method("POST", |route| -> route: equals("/humans"), |res, req| {
      let user = req: json() # from json, get data from POST request
      user: put("id", uuid(): toString())
      res
        : code(201)
        : json(user) # return json representation of the user with 201 status code
    })

    # protected route
    # ---------------------------------------------------------
    var admin = false
    let isAdmin = |res, req| {
      if admin isnt true {
        res: json(DynamicObject(): message("ONLY FOR ADMIN"))
      }
      return admin
    }

    app: method("GET", |route| -> route: startsWith("/admin"), isAdmin, |res, req| {
      res: json(DynamicObject(): message("Hello from admin"))
    })

    # generate html report error
    app: method("GET", |route| -> route: equals("/generror"), |res, req| {
      let division = 5 / 0
      res: content("ouch")
    })

  })
  
  server: start(">>> http://localhost:8080/")
  
}