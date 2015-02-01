<humans-list>

    <ul>
        <li each="{humans}">{id} {firstName} {lastName} <a href="/#humans/{id}/remove">Remove</a></li>
    </ul>

    var self = this;

    var humansCollection = this.opts.collection

    setInterval(function () {

        humansCollection.fetch().then(function(data) {})

    }, 500);

    humansCollection.on("sync", function() {
        self.humans = humansCollection.toJSON();
        self.update();
    });

    riot.route(function(collection, id, action) {
        console.log(collection, id, action) // action = remove
        humansCollection.get(id).destroy()
    })


</humans-list>