module humans

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange
import kiss.crypto
import kiss.jswtoken
import kiss.memdb

function main = |args| {

  let secret = "donald00"

  # data
  let db = memory(): log(false): name("humansdb.json"): ignition()

  if db: data(): get("humans") is null { db: data(): put("humans", map[]) }
  if db: data(): get("roles") is null { db: data(): put("roles", map[]) }

  let humansCollection = db: data(): get("humans")

  humansCollection: put("admin", map[
    ["id", "admin"],
    ["login","bob"],
    ["pwd", crypt(): secret(secret): DES(): encrypt("morane")],
    ["firstName","Bob"],
    ["lastName","Morane"],
    ["role", "admin"]
  ])

  let server = HttpServer("localhost", 8080, |app| {

    # static assets location
    app: static("/public", "index.html")

    app: $get("/humans", |res, req| {
      let humans = list[]
      humansCollection: each(|id, human| {
        humans: add(human)
      })
      res: json(humans)
    })

    app: $get("/humans/{id}", |res, req| {
      let human = humansCollection: get(req: params("id"))
      res: json(human)
    })

    app: $post("/humans", |res, req| {
      let human = req: json() # from json, get data from POST request
      let id = uuid(): toString()

      if human: get("pwd") isnt null {
        human: put("pwd", crypt(): secret(secret): DES(): encrypt(human: get("pwd")))
      }

      human: put("id", id)
      humansCollection: put(id, human)

      res
        : code(201)
        : json(human) # return json representation of the human with 201 status code
    })


    app: $put("/humans/{id}", |res, req| {
      let humanToUpdate = humansCollection: get(req: params("id"))
      let human = req: json()
      human: put("pwd", humanToUpdate: get("pwd"))
      humansCollection: put(req: params("id"), human)

      res
        : code(201) #?
        : json(human) # return json representation of the human with 201 status code
    })

    app: $delete("/humans/{id}", |res, req| {
      let humanToRemove = humansCollection: get(req: params("id"))
      humansCollection: delete(req: params("id"))
      res: code(202): json(humanToRemove)
    })

  })

  server: start(">>> http://localhost:"+ server: port() +"/")

}


