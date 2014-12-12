/**
 * Created by k33g_org on 11/12/14.
 */

import {Model, Collection, View, Router, $q, Observer} from "./tentacoolar/tentacoolar"


class Human extends Model {
	constructor (fields = {firstName:"John", lastName:"Doe"}) { // always initialize a model like that
		super({fields: fields, url:"/humans"});
	}
	get _id () { return this.get("_id"); }

	get firstName () { return this.get("firstName"); }
	set firstName (value) { this.set("firstName", value); return this; }

	get lastName () { return this.get("lastName"); }
	set lastName (value) { this.set("lastName", value); return this; }
}

class Humans extends Collection {
	constructor (humans) {
		super({model: Human,url: "/humans", models: humans});
	}
}

class HumanForm extends View {

	template () {return `
      <form>
        <input class="firstName" placeholder="firstName"/>
        <input class="lastName" placeholder="lastName"/>
        <button>add</button>
      </form>
  `;}

	constructor (humansCollection, message) {

		super({
			collection: humansCollection,
			selector: "human-form" // ref. to this.element
		});

		// display form
		this.render();

		this.button = this.find("button");
		this.firstName = this.find(".firstName");
		this.lastName = this.find(".lastName");

		this.button.on("click") ((event) => this.click(event));
	}

	click (event) {
		event.preventDefault();

		let human = new Human({
			firstName: this.firstName.value,
			lastName : this.lastName.value
		});

		human.save().then((data) => {

			this.collection.fetch().then(() => {
				this.firstName.value = "";
				this.lastName.value = "";

				this.collection.notifyObservers({event:"fetched"});
			})

		});

	}

	render () {
		this.html(this.template());
	}

}

class HumansList extends View {

	template (humans) {return `
		<ul>${
			humans.map(
				(human) => `
					<li>
						${human._id} -
						<b>${human.firstName}, ${human.lastName}</b>
						<a href="/#/humans/remove/${human._id}">Remove</a>
					</li>
	        `
			).join("")
		}</ul>
  `;}

	constructor (humansCollection) {

		super({
			selector : "humans-list",
			collection : humansCollection
		});

		new Observer({
			onMessage: (context) => {
				context.event == "fetched" ? this.render() : null;
			}
		}).observe(humansCollection)

	}

	render () {
		this.html(this.template(this.collection));
	}

}

let humansCollection = new Humans([]);

humansCollection.add(new Human()).add(new Human({firstName:"Jane", lastName:"Doe"}));

let humansList = new HumansList(humansCollection);

let humanForm = new HumanForm(humansCollection);

humansCollection.fetch();


let router = new Router();
router
	.add("/", (args) => { console.log("=== Home ==="); })
	.add("humans", (args) => {
		switch(args[0]) {
			case "remove":
				new Human({_id:args[1]}).delete().then(() => { humansCollection.fetch(); });
				break;
			case "list":
				break;
			default:
			//foo
		}
	})

router.listen();