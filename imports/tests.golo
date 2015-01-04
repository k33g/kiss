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
	function toBeInteger = |this| {
		require(this: actualValue() oftype Integer.class, this: actualValue() + " is not an Integer")
		println(" OK: " + this: actualValue() + " is an Integer")
		return this
	}
}

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

function expect = |value|-> matchers(): actualValue(value)
