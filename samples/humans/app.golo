module humans

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange
import kiss.crypto
import kiss.memdb

import com.auth0.jwt.JWTSigner
import com.auth0.jwt.JWTVerifier

function main = |args| {

  let secret = "donald00"

  # data
  let db = memory(): log(false): name("golodb.json"): ignition()

  if db: data(): get("humans") is null { db: data(): put("humans", map[]) }
  if db: data(): get("users") is null { db: data(): put("users", map[]) }


  let humansCollection = db: data(): get("humans")
  let usersCollection = db: data(): get("users")

  usersCollection: put("1234567890", map[
    ["id", "1234567890"],
    ["login","bob"],
    ["pwd", crypt(): secret(secret): DES(): encrypt("morane")],
    ["firstName","Bob"],
    ["lastName","Morane"],
    ["role", "admin"],
    ["features", map[
      ["humans","CRUD"]
    ]]
  ])

  usersCollection: put("1234567891", map[
    ["id", "1234567891"],
    ["login","john"],
    ["pwd", crypt(): secret(secret): DES(): encrypt("doe")],
    ["firstName","John"],
    ["lastName","Doe"],
    ["role", "sales"],
    ["features", map[
      ["humans","R"]
    ]]
  ])

  usersCollection: put("1234567892", map[
    ["id", "1234567892"],
    ["login","jane"],
    ["pwd", crypt(): secret(secret): DES(): encrypt("doe")],
    ["firstName","Jane"],
    ["lastName","Doe"],
    ["role", "sales"],
    ["features", map[
      ["humans","R"]
    ]]
  ])

  let check = |res, req, roles| {
    #----------------------------
    # check token
    #----------------------------
    var verify = null
    try {
      verify = JWTVerifier("bobMoraneHasSomeSecrets")
                : verify(req: headers()
                : get("x-access-token"): head())

      #println("user id " + verify: get("id"))
      #println("role id " + verify: get("role"))
    } catch(e) {
        res: code(403): json(message("Bad Hacker!"))
        return false
    }

    #----------------------------
    # check role(s)
    #----------------------------

    if roles: find(|role| -> role: equals(verify: get("role"))) isnt null {
      return true
    } else {
      res: code(403): json(message("Not appropriate role to do this!"))
      return false
    }
  }

  let server = HttpServer("localhost", 8080, |app| {

    # static assets location
    app: static("/public", "index.html")

    #$.ajax({
    #  type:'POST',
    #  url:'authenticate',
    #  data:{login:user, pwd:password}
    #})
    app: $post("/authenticate", |res, req| {
      let whoami = req: json()
      let login = whoami: get("login")
      let pwd = whoami: get("pwd")

      let searchUser = usersCollection: find(|id, user| -> user: get("login"): equals(login))

      if searchUser isnt null {
        let authenticatedUser = searchUser: value()
        #println("authenticatedUser " + authenticatedUser)
        #println("cryptedPwd " + authenticatedUser: get("pwd"))
        try {
          #println("User exists, verifying password")
          let decryptedPwd = crypt(): secret(secret): DES(): decrypt(authenticatedUser: get("pwd"))

          if decryptedPwd: equals(pwd) {
            # === here create web token ==

            let signer = JWTSigner("bobMoraneHasSomeSecrets")

            let token = signer: sign(map[
              ["id", authenticatedUser: get("id")],
              ["role", authenticatedUser: get("role")]
            ])

            #println("token " + token)
            res: code(200): json(map[
              ["token",token],
              ["user", authenticatedUser: clone(): delete("pwd")]
            ])

          } else {
            res: code(401): text("Authentication failed. Wrong password.")
          }

        } catch(e) {
          e: printStackTrace()
          res: code(401): text("Authentication failed. " + e: getMessage())
        }
      } else {
        res: code(401): text("Authentication failed. User not found.")
      }
    })

    app: $get("/yo", |res, req| -> check(res, req, ["admin", "sales"]), |res, req| {
      res
        : code(201)
        : json(DynamicObject(): message("yo")) # return json representation of the human with 201 status code
    })

    app: $get("/humans", |res, req| -> check(res, req, ["admin", "sales"]), |res, req| {
      let humans = list[]
      humansCollection: each(|id, human| {
        humans: add(human)
      })
      res: json(humans)
    })

    app: $get("/humans/{id}", |res, req| -> check(res, req, ["admin", "sales"]), |res, req| {
      let human = humansCollection: get(req: params("id"))
      res: json(human)
    })

    app: $post("/humans", |res, req| -> check(res, req, ["admin"]), |res, req| {
      let human = req: json() # from json, get data from POST request
      let id = uuid(): toString()

      if human: get("firstName"): equals("")  or human: get("lastName"): equals("") {
        res
          : code(400)
          : json(message("not empty!!!"))
      } else {
        human: put("id", id)
        humansCollection: put(id, human)

        res
          : code(201)
          : json(human) # return json representation of the human with 201 status code
      }

    })

    app: $put("/humans/{id}", |res, req| -> check(res, req, ["admin"]), |res, req| {
      let humanToUpdate = humansCollection: get(req: params("id"))
      let human = req: json()
      humansCollection: put(req: params("id"), human)

      res
        : code(201) #?
        : json(human) # return json representation of the human with 201 status code
    })

    app: $delete("/humans/{id}", |res, req| -> check(res, req, ["admin"]), |res, req| {
      let humanToRemove = humansCollection: get(req: params("id"))
      humansCollection: delete(req: params("id"))
      res: code(202): json(humanToRemove)
    })

  })

  server: start(">>> http://localhost:"+ server: port() +"/")

}


