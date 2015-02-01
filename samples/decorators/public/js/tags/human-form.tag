<human-form>
    <hr>
    <form onsubmit={ add }>
        <input placeholder="first name" name="firstName" onkeyup={ editFirstName }>
        <input placeholder="last name" name="lastName" onkeyup={ editLastName }>

        <button>Add</button>
    </form>
    <hr>

    var Human = this.opts.modelDefinition;

    editFirstName(e) {
        this.firstName = e.target.value
    }

    editLastName(e) {
        this.lastName = e.target.value
    }

    add(e) {
        var h = new Human({firstName: this.firstName, lastName: this.lastName})
        h.save()
    }

</human-form>