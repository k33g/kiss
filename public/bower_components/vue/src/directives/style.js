var prefixes = ['-webkit-', '-moz-', '-ms-']
var importantRE = /!important;?$/

module.exports = {

  deep: true,

  bind: function () {
    var prop = this.arg
    if (!prop) return
    this.prop = prop
  },

  update: function (value) {
    if (this.prop) {
      this.setCssProperty(this.prop, value)
    } else {
      if (typeof value === 'object') {
        for (var prop in value) {
          this.setCssProperty(prop, value[prop])
        }
      } else {
        this.el.style.cssText = value
      }
    }
  },

  setCssProperty: function (prop, value) {
    var prefixed = false
    if (prop.charAt(0) === '$') {
      // properties that start with $ will be auto-prefixed
      prop = prop.slice(1)
      prefixed = true
    }
    // cast possible numbers/booleans into strings
    if (value != null) {
      value += ''
    }
    var isImportant = importantRE.test(value)
      ? 'important'
      : ''
    if (isImportant) {
      value = value.replace(importantRE, '').trim()
    }
    this.el.style.setProperty(prop, value, isImportant)
    if (prefixed) {
      var i = prefixes.length
      while (i--) {
        this.el.style.setProperty(
          prefixes[i] + prop,
          value,
          isImportant
        )
      }
    }
  }

}