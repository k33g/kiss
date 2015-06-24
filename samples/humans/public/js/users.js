
(function (app) {

  /*
   var bob = new App.models.UserConnection({login:"bob", pwd:"morane"});
   bob.login();
   */
  app.models.UserConnection = Backbone.Model.extend({
    urlRoot: "authenticate",
    alreadyLogged: function() {
      if (window.localStorage.getItem('token') && window.localStorage.getItem('user')) {
        $.ajaxSetup({
          headers: {
            'x-access-token': window.localStorage.getItem('token')
          }
        });
        this.set("user", JSON.parse(window.localStorage.getItem('user')));
      }
    },
    login: function() {
      var self = this;
      return this.save().then(function(data) {
        window.localStorage.setItem('token', data.token);
        window.localStorage.setItem('user', JSON.stringify(data.user));
        console.log("authenticate", data);
        $.ajaxSetup({
          headers: {
            'x-access-token': data.token
          }
        });

        self.set("token", data.token);
        self.set("pwd", null);

      }).fail(function(err) {
        window.localStorage.removeItem('token');
        $.ajaxSetup({
          headers: {
            'x-access-token': null
          }
        });
      })
    },
    logout: function () {
      this.set("token", null);
      window.localStorage.removeItem('token');
      window.localStorage.removeItem('user');
      $.ajaxSetup({
        headers: {
          'x-access-token': null
        }
      });
      return this;
    }
  });

  return app;

}(App));