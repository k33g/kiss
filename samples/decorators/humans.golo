module humans

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange
import kiss.decorators

struct humansController = { db }

augment humansController {

  @GET("/humans")
  function getAll = |this, app| -> app: response(): json(this: db())

  @GET("/humans/{id}")
  function getOne = |this, app| {
    let userToFind = this: db()
      : find(|user| ->
        user: get("id"): equals(app: request(): params("id"))
      )
    app: response(): json(userToFind)
  }

  @DELETE("/humans/{id}")
  function deleteOne = |this, app| {
    let userToRemove = this: db()
      : find(|user| ->
        user: get("id"): equals(app: request(): params("id"))
      )
    this: db(): remove(userToRemove)
    app: response(): code(202): json(userToRemove)
  }

  @POST("/humans")
  function insertOne = |this, app| {
    let user = app: request(): json() # from json, get data from POST request
    user: put("id", uuid(): toString())
    this: db(): add(user)
    app: response()
      : code(201)
      : json(user) # return json representation of the user with 201 status code
  }

}

struct helloController = {
  message
}
augment helloController {
  @GET("/hello")
  function hello = |this, app| -> app: response(): html(this: message())
}



@STATIC("/public", "index.html") # static assets location
function initialize = |app, humanCtrl, helloCtrl| {
  # do stuff

  # define routes
  humanCtrl: getAll(app)
  humanCtrl: getOne(app)
  humanCtrl: deleteOne(app)
  humanCtrl: insertOne(app)

  helloCtrl: hello(app)

}

function main = |args| {

  let humans = list[
    map[["id", uuid()], ["firstName", "Bob"],["lastName", "Morane"]],
    map[["id", uuid()], ["firstName", "John"],["lastName", "Doe"]],
    map[["id", uuid()], ["firstName", "Bruce"],["lastName", "Wayne"]],
    map[["id", uuid()], ["firstName", "Clark"],["lastName", "Kent"]],
    map[["id", uuid()], ["firstName", "Peter"],["lastName", "Parker"]],
    map[["id", uuid()], ["firstName", "Jane"],["lastName", "Doe"]]
  ]

  let humanCtrl = humansController(humans)
  let helloCtrl = helloController("Kiss Framework")


  let server = HttpServer("localhost", 8080, |app| {

    initialize(app, humanCtrl, helloCtrl)

  })
  
  server: start(">>> http://localhost:"+ server: port() +"/")

}