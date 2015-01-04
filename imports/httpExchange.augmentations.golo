module kiss.httpExchange.augmentations

import kiss.httpExchange

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
