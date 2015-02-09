<container>
    <p></p>
    /*--- start --*/
    var self = this;
    var converter = new Showdown.converter();

    $(function() {
        $.get(self.opts["md-file"]).then(function (data) {
            $("p").html(converter.makeHtml(data));
        })
    });

</container>


