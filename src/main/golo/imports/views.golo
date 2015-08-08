module kiss.views

struct view = {
  rsrc,
  data,
  compiledTemplate
}

augment view {
  function template = |this, tplSource| {
    let tpl = "<%@params data, rsrc %>" + tplSource
    this: compiledTemplate(gololang.TemplateEngine(): compile(tpl))
    return this
  }
  function render = |this| {
    return this:compiledTemplate()(this: data(), this: rsrc())
  }
  function addResource = |this, name, rsrcContent| {
    if this: rsrc() is null { this: rsrc(map[]) }
    this: rsrc(): put(name, rsrcContent)
    return this
  }
  function loadResource = |this, name, url| {
    if this: rsrc() is null { this: rsrc(map[]) }
    this: rsrc(): put(name, fileToText(currentDir()+"/"+url, "UTF-8"))
    return this
  }
}
