module kiss.tests

struct matchers = {
	actualValue
}

#TODO: add colors
augment matchers {
 	function toEqual = |this, expectedValue| {
		require(this: actualValue(): equals(expectedValue), this: actualValue() + " isn't equal to " + expectedValue)
		println(" OK: " + this: actualValue() + " is equal to " + expectedValue)
		return this
	}
	function notToEqual = |this, expectedValue| {
		require(not this: actualValue(): equals(expectedValue), this: actualValue() + " is equal to " + expectedValue)
		println(" OK: " + this: actualValue() + " is not equal to " + expectedValue)
		return this
	}
  function toBeLessThan = |this, expectedValue| {
    require(this: actualValue() < expectedValue, this: actualValue() + " isn't less than " + expectedValue)
    println(" OK: " + this: actualValue() + " is less than " + expectedValue)
    return this
  }
  function notToBeLessThan = |this, expectedValue| {
    require(not this: actualValue() < expectedValue, this: actualValue() + " is less than " + expectedValue)
    println(" OK: " + this: actualValue() + " is not less than " + expectedValue)
    return this
  }
	function toBeInteger = |this| {
		require(this: actualValue() oftype Integer.class, this: actualValue() + " is not an Integer")
		println(" OK: " + this: actualValue() + " is an Integer")
		return this
	}
}

augmentation stringMatchers = {
  function toContain = |this, expectedValue| {
    require(
      this: actualValue(): contains(expectedValue),
      this: actualValue() + " doesn't contain " + expectedValue
    )
    println(" OK: " + this: actualValue() + " contains " + expectedValue)
    return this
  }
  function toStartWith = |this, expectedValue| {
    require(
      this: actualValue(): startsWith(expectedValue),
      this: actualValue() + " doesn't start with " + expectedValue
    )
    println(" OK: " + this: actualValue() + " starts with " + expectedValue)
    return this
  }
}

augment matchers with stringMatchers


# suites : describe

function describe = |whatIsBeingTested, suiteImplementation| { # suiteImplementation is a closure (lambda?)
	println("-- SUITE ----------------------------------------")
	println(" " + whatIsBeingTested)
	println("-------------------------------------------------")

	suiteImplementation()
}

# specs (it)

function it = |titleOfTheSpec, specFunction| {
	println(" " + "Spec: " + titleOfTheSpec)
	specFunction()
}

function expect = |value| -> matchers(): actualValue(value)


# Tools
----
  let t = timer(): start(|self| {
    Thread.sleep(500_L)
  }): stop(|self|{
    println(self: duration() + " ms")
  })
----
struct timer = {
  begin, end, duration
}
augment timer {
  function start = |this| {
    this: begin(java.lang.System.currentTimeMillis())
    return this
  }
  function start = |this, callback| {
    this: begin(java.lang.System.currentTimeMillis())
    callback(this)
    return this
  }
  function stop = |this| {
    this: end(java.lang.System.currentTimeMillis())
    this: duration(this: end() - this: begin())
    return this
  }
  function stop = |this, callback| {
    this: end(java.lang.System.currentTimeMillis())
    this: duration(this: end() - this: begin())
    callback(this)
    return this
  }
}
