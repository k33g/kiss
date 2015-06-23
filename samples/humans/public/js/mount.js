
(function (app) {

  var userConnection = new app.models.UserConnection()
    , broker = new app.Broker();

  app.routerInitialize(broker);

  riot.mount("login-form", {
    connection: userConnection,
    broker: broker
  });

  riot.mount("features-card", {
    broker: broker
  });

  return app;

}(App));