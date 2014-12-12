module humans

import kiss

function main = |args| {

  let humans = list[
    map[["_id", uuid()], ["firstName", "Bob"],["lastName", "Morane"]],
    map[["_id", uuid()], ["firstName", "John"],["lastName", "Doe"]],
    map[["_id", uuid()], ["firstName", "Bruce"],["lastName", "Wayne"]],
    map[["_id", uuid()], ["firstName", "Clark"],["lastName", "Kent"]],
    map[["_id", uuid()], ["firstName", "Peter"],["lastName", "Parker"]],
    map[["_id", uuid()], ["firstName", "Jane"],["lastName", "Doe"]]
  ]

  let server = HttpServer("localhost", 8080, |app| {

    # static assets location
    app: static("/public", "index.html")

    app: route("GET", "/humans", |res, req| {
      res: json(humans)
    })

    app: route("DELETE", "/humans/{id}", |res, req| {
      let userToRemove = humans
        : find(|user| ->
          user: get("_id"): equals(req: params("id"))
        )
      humans: remove(userToRemove)
      res: code(202): json(userToRemove)
    })


    app: method("POST", |route| -> route: equals("/humans"), |res, req| {
      let user = req: json() # from json, get data from POST request
      user: put("_id", uuid(): toString())
      humans: add(user)
      res
        : code(201)
        : json(user) # return json representation of the user with 201 status code
    })

  })
  
  server: start(">>> http://localhost:"+ server: port() +"/")

}