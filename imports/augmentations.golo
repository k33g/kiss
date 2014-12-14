module kiss.augmentations

import kiss.httpExchange

augment  kiss.httpExchange.types.httpExchange {
  function $get = |this, templateRoute, work| -> this: route("GET", templateRoute, work)
  function $post = |this, templateRoute, work| -> this: route("POST", templateRoute, work)
  function $delete = |this, templateRoute, work| -> this: route("DELETE", templateRoute, work)
  function $put = |this, templateRoute, work| -> this: route("PUT", templateRoute, work)
}