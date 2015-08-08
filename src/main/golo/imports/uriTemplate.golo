module kiss.uriTemplate

import java.util.regex.Matcher
import java.util.regex.Pattern


struct uriTemplate = {
    template            # String
  , regex               # Pattern
  , vars                # String[]
  , charCnt             # int

}

# Inspiration
#
# org.springframework.web.util : Class UriTemplate
augment uriTemplate {
  # Determine if uri is matched by this uri template and return a map of variable
  # values if it does.
  function matchString = |this, uri| { # string / return map  of variable values (or null, if no match, or empty if no vars)
    let values = map[] # Map<String, String>

    # if (uri != null && uri.length() != 0)
    if not (uri is null)  {
      if not (uri: length(): equals(0)) {
        let m = this: regex(): matcher(uri) # Matcher

        if m: matches() {
          values: put(m: groupCount(), 1.0_F)

          for (var i = 0, i < m: groupCount(), i = i +1) {
            var name = this: vars(): get(i)
            var value = m: group(i + 1)
            var existingValue = values: get(name)
            # if (existingValue != null && !existingValue.equals(value))
            if not (existingValue is null) {
              if not (existingValue: equals(value)) {
                return null
              }
            }
            values: put(this: vars(): get(i), value)
          }
        }
      }
    }
    return values
  }
}

function UriTemplate = |template| { # string

  # === constructor ===

  # VALID_URI           # Pattern
  # VARIABLE            # Pattern
  # VARIABLE_REGEX      # String

  #let VALID_URI = Pattern.compile("^/(([\\w\\-]+|\\{([a-zA-Z][\\w]*)\\})(;*)/?)+(\\.\\w+$)?|^/$")
  let VARIABLE = Pattern.compile("\\{([a-zA-Z]\\w*)\\}")
  let VARIABLE_REGEX = "(.*?)"

  #ensure template is syntactically correct
  #println(VALID_URI: matcher(template))

  # convert uri template into equivalent regular expression
  # and extract variable names
  let templateRegex = java.lang.StringBuilder()         # StringBuilder
  let names = list[]                                    # new ArrayList<String>() / List<String>
  var charCnt = 0                                       # int
  var start = 0                                         # int
  var end = 0                                           # int
  let matcher = VARIABLE: matcher(template)             # Matcher

  # Helper for constructing regular expression (escaping regex chars where necessary)
  let appendTemplate = |template, start, end, regex| { # params : String, int, int, StringBuilder / return int
    for (var i = start, i < end, i = i + 1) {
      let c = template: charAt(i)

      if not "(.?)": indexOf(c:toString()): equals(-1) {
        regex: append("\\")
      }
      regex: append(c)
    }
    return end - start
  }

  while matcher: find() {
    end = matcher: start()
    charCnt = charCnt +  appendTemplate(template, start, end, templateRegex)
    templateRegex: append(VARIABLE_REGEX)
    let name = matcher: group(1)
    names: add(name)
    start = matcher: end()
  }
  charCnt = charCnt + appendTemplate(template, start, template: length(), templateRegex)

  # initialize
  let strArray = java.lang.reflect.Array.newInstance(java.lang.String.class, names: size())

  let utiTpl = uriTemplate()
    : template(template)
    : charCnt(charCnt)
    : regex(Pattern.compile(templateRegex: toString()))
    : vars(strArray)

  names: toArray(utiTpl: vars())

  return utiTpl

}

