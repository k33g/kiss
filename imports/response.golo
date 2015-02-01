module kiss.response

struct response = {
    content
  , code      # status code
  , message   # not used for the moment
  , exchange
}

augment response {

  function send = |this| {
    this: message("OK") #TODO: send message?
    #  this: exchange(): sendResponseHeaders(this: code(), this: content(): length())
    this: exchange(): sendResponseHeaders(this: code(), this: content(): getBytes("UTF-8"): length()) #character encoding -> get number of bytes?

    this: exchange(): getResponseBody(): write(this: content(): getBytes())
    this: exchange(): close()  
  }

  function headers = |this| -> this: exchange(): getResponseHeaders()

  function contentType = |this, content_type| {
    this: headers(): set("Content-Type", content_type)
    return this
  }
  function contentType = |this| -> this: headers(): get("Content-Type")

  function json = |this, value| -> this: contentType("application/json;charset=UTF-8"): content(JSON.stringify(value)): send()
  function html = |this, value| -> this: contentType("text/html;charset=UTF-8"): content(value): send()
  function text = |this, value| -> this: contentType("text/plain;charset=UTF-8"): content(value): send()

  #function json = |this, value| -> this: contentType("application/json;charset=UTF-8"): content(JSON.stringify(value))
  #function html = |this, value| -> this: contentType("text/html;charset=UTF-8"): content(value)
  #function text = |this, value| -> this: contentType("text/plain;charset=UTF-8"): content(value)

  function allowCORS = |this, origin, methods, headers| {
    this: headers(): set("Access-Control-Allow-Origin", origin)
    this: headers(): set("Access-Control-Request-Method", methods)
    this: headers(): set("Access-Control-Allow-Headers", headers)
  }
  # set cookie with a value
  function cookie = |this, name, value| {
    this: headers(): add("Set-Cookie", name + "=" + value + ";")
    return this
  }
  # remove cookie
  function removeCookie = |this, name| {
    this: headers(): add("Set-Cookie", String.format("%s=; Expires=Thu, 01 Jan 1970 00:00:00 GMT", name + "=" + null))
    return this
  }

  function redirect = |this, location| {
      this: code(302): content("Redirecting ..."): headers(): set("Location", location)
      this: send()
      return this
  }

  function redirect = |this, location, code| {
      this: code(code): content("Redirecting ..."): headers(): set("Location", location)
      #this: content("Redirecting ...")
      #this: headers(): set("Location", location)
      this: send()
      return this
  }

  # === Server-Sent Events ===
  # http://www.html5rocks.com/en/tutorials/eventsource/basics/
  function SSEInit = |this| {
    #let responseHeaders = this: exchange(): getResponseHeaders()
    this: headers(): set("Content-Type", "text/event-stream;charset=UTF-8") # ? ;charset=UTF-8
    this: headers(): set("Cache-Control", "no-cache")
    this: headers(): set("Connection", "keep-alive")
    
    this: exchange(): sendResponseHeaders(200, 0)
    #this: content(".") # avoid 404, see KissHttpServer.golo
    this: message("OK") # avoid 404, see KissHttpServer.golo
    return this
  }

  function SSEWrite = |this, data| {
    let SSEData = "data:"+ data +"\n\n"
    this: exchange(): getResponseBody(): write(SSEData: getBytes())
    this: exchange(): getResponseBody(): flush()
    return this
  }
}
