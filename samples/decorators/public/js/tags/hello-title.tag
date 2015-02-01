<hello-title>
    <h1>{label}</h1>
    var self = this
    self.label ="HELLO";

    $.get("/hello", function(data) {
        console.log(data)
        self.label = data;
        self.update();

    });

</hello-title>