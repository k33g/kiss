module kiss.augmentations

import kiss.httpExchange
import gololang.Async
import gololang.concurrent.workers.WorkerEnvironment

----
 Add some syntactic glue to kiss rest methods

 Augmentation of kiss.httpExchange
 TODO: make a specific augmentation module
----
augment  kiss.httpExchange.types.httpExchange {
  function $get = |this, templateRoute, work| -> this: route("GET", templateRoute, work)
  function $post = |this, templateRoute, work| -> this: route("POST", templateRoute, work)
  function $delete = |this, templateRoute, work| -> this: route("DELETE", templateRoute, work)
  function $put = |this, templateRoute, work| -> this: route("PUT", templateRoute, work)

  function $get = |this, templateRoute, condition, work| -> this: route("GET", templateRoute, condition, work)
  function $post = |this, templateRoute, condition, work| -> this: route("POST", templateRoute, condition, work)
  function $delete = |this, templateRoute, condition, work| -> this: route("DELETE", templateRoute, condition, work)
  function $put = |this, templateRoute, condition, work| -> this: route("PUT", templateRoute, condition, work)
}

----
  Promise helper: it's easier to make asynchronous work

   Augmentation of gololang.concurrent.async.Promise
   TODO: make a specific augmentation module
----
augment gololang.concurrent.async.Promise {
----
 `env` is a worker environment
----
  function initializeWithWorker = |this, env, closure| {
    env: spawn(|message| {
      this: initialize(closure)
    }): send("")
    return this: future()
  }
----
 ...
----
  function initializeWithThread = |this, closure| {
    Thread({
      this: initialize(closure)
    }): start()
    return this: future()
  }
----
 ...
----
  function initializeWithJoinedThread = |this, closure| {
    let t = Thread({
      this: initialize(closure)
    })
    t: start()
    t: join()
    return this: future()
  }
}

