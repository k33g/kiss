module kiss.request

struct request = {
    data
  , exchange
  , parameters
}

augment request {

  function params = |this, key| -> this: parameters(): get(key)

  function method = |this| -> this: exchange(): getRequestMethod()
  function uri = |this| -> this: exchange(): getRequestURI()
  function headers = |this| -> this: exchange(): getRequestHeaders()

  function json = |this| -> JSON.parse(this: data() orIfNull "{}")

  function splitRoute = |this| -> this: uri(): toString(): split("/"): asList(): filter(|part| -> not part:equals(""))
  # access request cookie by name
  function cookie = |this, name| {
    var cookie = null
    let cookiesParts = this: headers(): get("Cookie"): toString(): split(name + "=")
    if cookiesParts: length() > 1 { cookie = cookiesParts: get(1): split(";"): get(0): split("]"): get(0) }
    return cookie
  }
  # get map of all cookies
  function cookies = |this| {
    let cookies = map[]
    let cookiesString = this: headers(): get("Cookie"): toString()
    let cookiesList = cookiesString: substring(1, cookiesString: length() - 1): split(";"): asList()
    cookiesList: each(|cookie| {
      let cookieParts = cookie: split("=")
      let name = cookieParts: get(0)
      let value = cookieParts: get(1)
      cookies: put(name, value)
    })
    return cookies
  }
}

