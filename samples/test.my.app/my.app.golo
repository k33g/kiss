module my.app

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange
import kiss.augmentations
import kiss.http
import kiss.tests

import gololang.Async


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

  server: watch(["/"], |events| {
      events: each(|event| -> println(event: kind() + " " + event: context()))
      java.lang.System.exit(1) #exit and restart
  })

  # promise tool
  let callRoute = |route| {
    return promise(): initializeWithJoinedThread(|resolve, reject| {
      try {
        let r = getHttp("http://localhost:"+ server: port() + route, "application/json;charset=UTF-8")
        resolve(r)
      } catch (e) {
        reject(e)
      }
    })
  }

  #--------------------------------
  # run bdd tests
  #--------------------------------

  describe("Testing welcome routes", {

    it("We can call /hello", {

      callRoute("/hello"): onSet(|result| { # if success

        expect(result: code()): toEqual(200)
        expect(result: message()): toEqual("OK")
        expect(result: text()): toEqual(JSON.stringify(message("hello")))

      }): onFail(|err| { # if failed
        println(err)
        expect(true): toEqual(false)
      })
    })

    it("We can call /hi", {

      callRoute("/hi"): onSet(|result| { # if success

        expect(result: code()): toEqual(200)
        expect(result: message()): toEqual("OK")
        expect(result: text()): toEqual(JSON.stringify(message("hi")))

      }): onFail(|err| { # if failed
        println(err)
        expect(true): toEqual(false)
      })
    })


  })


}