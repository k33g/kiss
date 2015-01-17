module myview

import kiss
import kiss.request
import kiss.response
import kiss.httpExchange
import kiss.http
import kiss.views


function HomeView = -> view(): template("""
  <h1><%= rsrc: get("title") %></h1>
  <h3></h3>
  <hr>
  <h2><%= data: get(0) %></h2>
  <h2><%= data: get(1) %></h2>
  <hr>
  <script><%= rsrc: get("tools") %></script>
  <%= rsrc: get("footer") %>
  <script><%= rsrc: get("someCode") %></script>
"""
)

function main = |args| {

  # compile template
  let homeView = HomeView()
    : addResource("title", "Hello World From Kiss! with Love <3") # add once (static resource)
    : loadResource("tools", "/tools.js")
    : loadResource("footer", "/footer.html") # add once (pre load static resource)
    : addResource("someCode","""
        document.querySelector("h3").innerHTML = "this is a little subtitle";
        console.log("Hi! I'm a message ...")
    """
    )


  let server = HttpServer("localhost", 8080, |app| {

    app: $get("/", |res, req| {
      res: html(
        homeView: data(list["Bob Morane", "John Doe"]): render()
      )
    })

  })
  
  server: start(">>> http://localhost:"+ server: port() +"/")

  server: watch(["/"], |events| {
      events: each(|event| -> println(event: kind() + " " + event: context()))
      java.lang.System.exit(1)
  })


}