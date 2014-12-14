module kiss.httpExchange

import kiss.contentTypes
import kiss.uriTemplate
import kiss.request
import kiss.response

struct httpExchange = {
    response
  , request
}

augment httpExchange {

  function all = |this, work| -> work(this: response(), this: request())

  # app: route("GET", "/hello/{name}/{home}", |res, req| -> println(req: params()))
  function route = |this, method, routeTemplate, work| {
    let params = UriTemplate(routeTemplate): matchString(this: request(): uri(): toString())
    if this: request(): method(): equals(method)
    and params: size() > 0 {
      this: request(): parameters(params)
      work(this: response(), this: request())
    }
    return this
  }

  function route = |this, method, routeTemplate, condition, work| {
    let params = UriTemplate(routeTemplate): matchString(this: request(): uri(): toString())
    if this: request(): method(): equals(method)
    and params: size() > 0
    and condition(this: response(), this: request()) {
      this: request(): parameters(params)
      work(this: response(), this: request())
    }
    return this
  }

  function method = |this, method, work| {
    if this: request(): method(): equals(method) {
      work(this: response(), this: request())
    }
    return this
  }

  function method = |this, method, routeCondition, work| {
    if this: request(): method(): equals(method)
    and routeCondition(this: request(): uri(): toString()) {
      work(this: response(), this: request())
    }
    return this
  }

  function method = |this, method, routeCondition, condition, work| {

    if this: request(): method(): equals(method)
    and routeCondition(this: request(): uri(): toString())
    and condition(this: response(), this: request()) {
      work(this: response(), this: request())
    }
    return this
  }


  # getContentTypes()
  function contentTypeOfFile  = |this, path| ->
    getContentTypes()
      : get(path: substring(path: lastIndexOf(".") + 1))
      orIfNull "text/plain;charset=UTF-8"

  function static = |this, staticAssetsDirectory, defaultPage| {
    # Home
    this: method("GET", |route| -> route: equals("/"), |res, req| {
      let path = currentDir() + staticAssetsDirectory + req: uri(): toString() + defaultPage
      res
        : contentType("text/html")
        : content(fileToText(path, "UTF-8"))
        : send()
    })

    # Serve assets
    this: method("GET", |route| -> not route: equals("/"), |res, req| {

      let path = currentDir() + staticAssetsDirectory + req: uri(): toString()

      if fileExists(java.io.File(path)) {
        let contentTypeOfAsset = this: contentTypeOfFile(path)
        let content = fileToText(path, "UTF-8")
        res
          : contentType(contentTypeOfAsset)
          : content(content)
          : send()
      }

    })

    return this
  } # end of function static

} # end of augment httpExchange
