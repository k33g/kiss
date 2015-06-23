
(function (app) {

  app.models.Human = Backbone.Model.extend({urlRoot:"/humans"});
  app.collections.Humans = Backbone.Collection.extend({url: "/humans", model:app.models.Human});

  return app;

}(App));