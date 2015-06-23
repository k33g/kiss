
var root = this;

if (typeof exports === 'undefined') {
  root.App = root.App || {};
}

(function(app) {

  app.Broker = function () {
    this.observables = [];
    this.observe = function (observable) {
      this.observables.push(observable);
    };

    this.emit = function (message, data) {
      _.each(this.observables, function (observable) {
        observable.trigger(message, data)
      });
    }
  };

  app.models = {};
  app.collections = {};

  return app;
})(root.App || exports);
