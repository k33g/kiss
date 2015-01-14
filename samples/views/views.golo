module myview

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange
import kiss.httpExchange.augmentations
import kiss.http
import kiss.views


function HomeView = -> view(): template("""
  <h1><%= rsrc: get("title") %></h1>
  <hr>
  <h2><%= data: get(0) %></h2>
  <h2><%= data: get(1) %></h2>
  <hr>
  <%= rsrc: get("footer") %>
"""
)

function main = |args| {

  # compile template
  let homeView = HomeView()
    : addResource("title", "Hello World From Kiss! with Love <3") # add once (static resource)
    : loadResource("footer", "/footer.html") # add once (pre load static resource)


  let server = HttpServer("localhost", 8080, |app| {

    app: $get("/", |res, req| {
      res: html(
        homeView: data(list["Bob Morane", "John Doe"]): render()
      )
    })

  })
  
  server: start(">>> http://localhost:"+ server: port() +"/")

}