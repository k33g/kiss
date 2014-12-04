module sample01

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

