
(function (app) {

  app.routerInitialize = function(broker) {

    riot.route(function(what, param, id) {
      console.log("From Router ->",what, param, id);

      //http://localhost:8080/#load/features/help-card
      /*
      if (what=="load") {
        broker.emit("load:"+param, id);
      }
      */


    }.bind(this));

    riot.route.start();
  }

  return app;

}(App));
