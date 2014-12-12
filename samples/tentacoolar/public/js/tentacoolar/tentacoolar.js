/**
 * Created by k33g_org on 11/12/14.
 */

export class Observable {

	constructor (observers=[]) {
		this.observers = observers;
	}

	addObserver (observer) {
		this.observers.push(observer);
		return this;
	}

	addObservers (observers) {
		observers.forEach((observer) => {
			this.observers.push(observer);
		});
		return this;
	}

	notifyObservers (context) {
		this.observers.forEach((observer) => {
			observer.update(context)
		});
		return this;
	}

/*TODO: removeObserver etc. ...*/
}

export class Observer {

	constructor (options = { onMessage: (context) => { console.log(context);} }) {
		Object.assign(this, options);
	}

	update (context) {
		this.onMessage(context)
	}

	observe (observable) {
		observable.addObserver(this);
	}
	/*
	 TODO: observerAbilities
	 */
}

class RequestError extends Error {
	constructor (statusCode, statusMessage, response) {
		this.message = statusMessage;
		this.code = statusCode;
		this.response = response
		super()
	}
}

export class Request {

	constructor (url = "/") {
		this.request = new XMLHttpRequest();
		this.url = url;
		this.method = null;
		this.data = null;
	}

	sendRequest (json=true) {

		return new Promise((resolve, reject) => {
			this.request.open(this.method, this.url);

			if (this.header) {
				console.log("HEADER", this.header)
				this.request.setRequestHeader(this.header.key, this.header.value)
			}

			this.request.onload = () => {
				// If the request was successful
				if (this.request.status === 200) {
					//console.log("this.request.response", this.request.response)
					if(json) { // JSON response
						resolve(JSON.parse(this.request.response));
					} else {
						resolve(this.request.response);
					}

				} else { /* oups */
					reject(new RequestError(this.request.status, this.request.statusText, this.request.response));
				}
			}
			// Handle network errors
			this.request.onerror = function() {
				reject(new Error("Network Error"));
			};

			this.request.setRequestHeader("Content-Type", "application/json");
			this.request.send(this.method === undefined ? null : JSON.stringify(this.data));
		});
	}

	setHeader(key, value) {
		this.header = {key: key, value: value}
		console.log("header", this.header)
		return this;
	}

	getText () {
		this.method = "GET";
		this.data = {};
		return this.sendRequest(false);
	}
	//TODO: querystring?
	get () {
		this.method = "GET";
		this.data = {};
		return this.sendRequest();
	}

	post (jsonData) {
		this.method = "POST";
		this.data = jsonData;
		return this.sendRequest();
	}

	put (jsonData) {
		this.method = "PUT";
		this.data = jsonData;
		return this.sendRequest();
	}

	delete () {
		this.method = "DELETE";
		this.data = {};
		return this.sendRequest();
	}
}

export class Model extends Observable {

	constructor (options = {fields: {}, url: "/", observers: []}) {
		Object.assign(this, options);
		super(this.observers);
	}

	get (fieldName) {
		return this.fields[fieldName];
	}

	set (fieldName, value) {
		this.fields[fieldName] = value;
		return this;
	}

	toString () {
		return JSON.stringify(this.fields)
	}

	/*--- sync ---*/


	id() { return this.get("_id");}

	save () {

		if (this.id() == undefined) {
			// create (insert)
			return new Request(this.url).post(this.fields)
				.then((data) => {
					this.fields = data;
					this.notifyObservers({event: "created", model: this});
					return data;
				})
				.catch((error) => error)
		} else {
			// update
			return new Request(`${this.url}/${this.id()}`).put(this.fields)
				.then((data) => {
					this.fields = data;
					this.notifyObservers({event: "updated", model: this});
					return data;
				})
				.catch((error) => error)
		}

	}

	fetch (id) {

		if (id == undefined) {
			new Request(`${this.url}/${this.id()}`).get()
				.then((data) => {
					this.fields = data;
					this.notifyObservers({event: "fetched", model: this});
					return data;
				})
				.catch((error) => error)
		} else {
			new Request(`${this.url}/${id}`).get()
				.then((data) => {
					this.fields = data;
					this.notifyObservers({event: "fetched", model: this});
					return data;
				})
				.catch((error) => error)
		}

	}

	delete (id) {

		if (id == undefined) {
			//console.log("delete",this.id())
			return new Request(`${this.url}/${this.id()}`).delete()
				.then((data) => {
					this.fields = data;
					this.notifyObservers({event: "deleted", model: this});
					return data;
				})
				.catch((error) => error)
		} else {
			return new Request(`${this.url}/${id}`).delete()
				.then((data) => {
					this.fields = data;
					this.notifyObservers({event: "deleted", model: this});
					return data;
				})
				.catch((error) => error)
		}
	}

}


export class Collection extends Observable {

	constructor (options = {model: {}, url: "/", models: [], observers: []}) {
		Object.assign(this, options);
		super(this.observers);
	}

	toString () {
		return JSON.stringify(this.models);
	}

	add (model) {
		this.models.push(model);
		this.notifyObservers({event: "added", model: model});
		return this;
	}

	each (callbck) {
		this.models.forEach(callbck)
	}

	filter (callbck) {
		return this.models.filter(callbck)
	}

	map (callbck) {
		return this.models.map(callbck)
	}


	size () { return this.models.length; }

	/*--- sync ---*/

	fetch () {

		return new Request(this.url).get().then((models) => {
			this.models = []; /* empty list */

			models.forEach((fields) => {
				this.add(new this.model(fields)); // always initialize a model like that
			});

			this.notifyObservers({event: "fetched", models:models});
			return models;
		})
			.catch((error) => error)


	}
	/* TODO: add search() facilities */

}

let q = (selector) => {

	var nodes = Array.from(document.querySelectorAll(selector));

	if (nodes.length == 1) {
		nodes = nodes[0];
	} else {

		Object.assign(nodes, {
			first ()  { return this[0]; },
			last () { return this[this.length-1]; }
		});
	}

	nodes.find = q;

	nodes.on = (eventName) => {
		return (callBack) => {
			nodes.addEventListener(eventName, (event) => callBack(event));
		};
	}

	return nodes;
}

export function $q(selector) { return q(selector); }

export class View extends Observable {

	constructor (options={selector: "", observers: []}) {
		Object.assign(this, options);
		this.element = $q(this.selector);
		super(this.observers);
	}

	html (code) {
		this.element.innerHTML = code;
	}

	show () {
		this.element.style.display = "block"
	}

	hide () {
		this.element.style.display = "none"
	}

	toggle () {
		(this.element.style.display == "block" || this.element.style.display == "") ? this.hide() : this.show();
	}

	/* $q("h3").attributes["data-model"].value */

	attribute (attrName) {
		return this.element.attributes[attrName];
	}

	attributes () {
		return this.element.attributes;
	}

	find (selector) {
		return this.element.find(selector);
	}

	on (eventName) {
		return this.element.on(eventName);
	}
}

export class Router {

	constructor (options={}) {
		Object.assign(this, options);
		this.routes = new Map();
		this.routes.set("/",(args)=>{});
	}

	add (uri, action) {
		this.routes.set(uri, action);
		return this;
	}

	match (uri) { //using hash

		// remove #/ from uri
		uri = uri.replace("#\/","");

		// ie: http://localhost:3006/#/hello/bob/morane
		// becomes /hello/bob/morane

		// to split uri with "/" and keep only no empty items
		let uriParts = uri.split("/").filter((part)=>part.length>0);

		// ie: ["hello", "bob", "morane"]

		// key to search -> "hello"
		let route = uriParts[0];
		// parameters to pass to the method -> ["bob", "morane"]
		let params = uriParts.slice(1);

		// het method
		let method = this.routes.get(route);

		// run method
		if (method) {
			method(params)
		} else {
			this.routes.get("/")(params)
		}
	}

	listen () {
		// when router is listening
		// check url at first time (first load) (useful to bookmark functionality)
		this.match(window.location.hash);

		/* subscribe to onpopstate */
		window.onpopstate = (event) => {
			this.match(window.location.hash);
		};
	}

}