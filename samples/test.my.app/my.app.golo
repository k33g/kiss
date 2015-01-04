module my.app

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange
import kiss.httpExchange.augmentations
import kiss.http
import kiss.tests

import gololang.Async

# create your own matcher
augmentation halfMatcher = {
	function toBeHalf = |this, expectedValue| {
		require(
			this: actualValue(): equals(expectedValue/2),
			this: actualValue() + " isn't half " + expectedValue
		)
		println(" OK: " + this: actualValue() + " is half " + expectedValue)
		return this
	}
}

augment kiss.tests.types.matchers with halfMatcher

function main = |args| {


  let server = HttpServer("localhost", 8080, |app| {

    app: $get("/hello"
    , |res, req| {
      res: json(message("hello"))
      #res: code(666): json(message("hello")) -> to generate an error
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

  #--------------------------------
  # run bdd tests
  #--------------------------------

  # try your matcher
  expect(4): toBeHalf(8): toBeInteger()

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

  println("-------------------------------------------------")
  println("Ctrl + c to exit ...")

}