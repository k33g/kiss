module kiss.http

import kiss.promise.augmentations
import gololang.Async


#function JSON = -> "application/json;charset=UTF-8"
#function HTML = -> "text/html;charset=UTF-8"

struct response = {
  code,
  message,
  text
}

function getHttp = |url, contenType| {
  try {
    let obj = java.net.URL(url) # URL obj
    let con = obj: openConnection() # HttpURLConnection
    con: setRequestMethod("GET")
    con: setRequestProperty("Content-Type", contenType)
    #add request header
    con: setRequestProperty("User-Agent", "Mozilla/5.0")

    let responseCode = con: getResponseCode() # int responseCode
    let responseMessage = con: getResponseMessage() # String responseMessage

    let responseText = java.util.Scanner(
      con: getInputStream(),
      "UTF-8"
    ): useDelimiter("\\A"): next() # String responseText

    return response(responseCode, responseMessage, responseText)
  } catch (err) {
    throw err
  }
}
