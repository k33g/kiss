module app

import kiss

function main = |args| {

  let server = HttpServer("localhost", 8080, |app| {

    #app: all(|res, req| { println("Hello") })

    app: static("/public", "index.html")

    # experimental : route template
    app: route("GET", "/hello/{firstname}/{lastname}", |res, req| {
      res: json(DynamicObject()
        : firstName(req: params("firstname"))
        : lastName(req: params("lastname"))
      )
    })

    app: method("GET", |route| -> route: startsWith("/humans/"), |res, req| {
      res: json(DynamicObject()
        : id(req: uri(): parts(): last())
        : parts(req: uri(): parts())
      )
    })

    # generate html report error
    app: method("GET", |route| -> route: equals("/generror"), |res, req| {
      let division = 5 / 0
      res: content("ouch")
    })

    app: method("GET", |route| -> route: equals("/setcookie"), |res, req| {
      let uuid = uuid()
      res: cookie("bob", uuid)
      res: json(DynamicObject(): newCookie(uuid))
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

    # CORS support
    app: method("GET", |route| -> route: equals("/cors/humans"), |res, req| {
      res: allowCORS("*", "*", "*")
      res: json(DynamicObject(): message("all humans"))
    })

    #app: route("GET", "/humans", |res, req| {
    #  res: json([
    #    map[["id", uuid()], ["firstName", "Bob"],["lastName", "Morane"]],
    #    map[["id", uuid()], ["firstName", "John"],["lastName", "Doe"]],
    #    map[["id", uuid()], ["firstName", "Jane"],["lastName", "Doe"]]
    #  ])
    #})


    app: method("GET", |route| -> route: equals("/humans"), |res, req| {
      res: json([
        map[["id", uuid()], ["firstName", "Bob"],["lastName", "Morane"]],
        map[["id", uuid()], ["firstName", "John"],["lastName", "Doe"]],
        map[["id", uuid()], ["firstName", "Jane"],["lastName", "Doe"]]
      ])
    })

    app: method("POST", |route| -> route: equals("/humans"), |res, req| {

      let user = req: json() # from json
      user: put("id", uuid(): toString())

      res
        : code(201)
        : json(user)

    })

    app: method("GET", |route| -> route: startsWith("/bob"), |res, req| {
      res: json(DynamicObject(): message("Hello from bob"))
    })

    # ---------------------------------------------------------
    var admin = false
    let isAdmin = |res, req| {
      if admin isnt true {
        res: json(DynamicObject(): message("ONLY FOR ADMIN"))
      }
      return admin
    }

    # ---------------------------------------------------------
    var isAdminService = |route| -> route: startsWith("/admin")
    # ---------------------------------------------------------

    # protected route: isAdmin()
    app: method("GET", isAdminService, isAdmin, |res, req| {
      res: json(DynamicObject(): message("Hello from admin"))
    })

    app: method("POST", |route| -> route: equals("/something"), |res, req| {
      res
        : code(201)
        : json(map[
            ["message", "ok"]
          , ["code", res: code()]
          , ["data", req: data()]
          , ["hello", req: json(): get("firstName")]
        ])

    })

  })

  server: start(">>> http://localhost:8080/")

}
