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

class HumansList extends View {

	template (humans) {return `
		<ul>${
			humans.map(
				(human) => `
					<li>
						${human._id} -
						<b>${human.firstName}, ${human.lastName}</b>
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

let humansList = new HumansList(humansCollection);

humansCollection.fetch();
