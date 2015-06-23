# Caution: Quick and dirty JsonWebToken Implementation.
# It's better to use an external library
# It's only a sandbox
module kiss.jswtoken

import kiss.crypto

struct jswtoken = {
  encryptor
}

augment jswtoken {

  function sign = |this, data, options| {
    let token = JSON.stringify(map[["GoloJSONWebToken","42"],["data", data], ["options", options]])
    #let token = JSON.stringify(map[["data", data], ["options", options]])

    return this: encryptor(): encrypt(token)
  }

  function verify = |this, token, callback| {
    let decryptToken = JSON.parse(this: encryptor(): decrypt(token))
    try {
      if decryptToken: get("GoloJSONWebToken"): equals("42") {
        decryptToken: delete("GoloJSONWebToken")
        callback(null, decryptToken)
      } else {
        callback(java.lang.Error("This is not a GoloJSONWebToken"), null)
      }
    } catch(e) {
      callback(java.lang.Error(e: getMessage()), null)
    }
  }
}

# golo golo --files crypto.golo json.web.token.golo
# for tests
function main = |args| {

  let token = jswtoken(crypt(): secret("bob-morane-00001"): AES()): sign(
    data = DynamicObject(): firstName("Bob"): lastName("Morane"),
    options = map[["yo","bob"]]
  )
  println(token)

  let strToken = "vjw3BDp4Yv+vM8UayimCgsXE6CLy+cZmSdOQq77K/dwVESkUyD57l6jNaCwSqxVZsp52TnoBfhSiW9ERnMCDrmdq+7Yfb09r4PCULUSwX72XWw+BGCauEvM8MM/RpCa3"

  jswtoken(crypt(): secret("bob-morane-00001"): AES()): verify(
    token = strToken,
    callback = |error, token| {
      if error isnt null {
        println("oups")
        return null
      }
      println(token)
    }
  )

}



