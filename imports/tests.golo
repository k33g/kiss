module kiss.tests

#TODO: colors

# suites : describe
function describe = |whatIsBeingTested, suiteImplementation| { # suiteImplementation is a closure (lambda?)
	#TODO: duration (start - end)
	println("-- SUITE ----------------------------------------")
	println(" " + whatIsBeingTested)
	println("-------------------------------------------------")
	# (try catch?)
	suiteImplementation()
}

# specs (it)

function it = |titleOfTheSpec, specFunction| {
	println(" " + "Spec: " + titleOfTheSpec)
	# (try catch?)
	specFunction()	# a set of matchers
}

let matchers = DynamicObject()

function getMatchers = -> matchers
	: define("toEqual", |this, expectedValue| {
			require(this: actualValue(): equals(expectedValue), this: actualValue() + " isn't equal to " + expectedValue)
			println(" OK: " + this: actualValue() + " is equal to " + expectedValue)
		})
	: define("notToEqual", |this, expectedValue| {
			require(not this: actualValue(): equals(expectedValue), this: actualValue() + " is equal to " + expectedValue)
			println(" OK: " + this: actualValue() + " is not equal to " + expectedValue)
		})


function expect = |value|-> getMatchers(): actualValue(value)

# specific matchers
function halfMatcher = -> DynamicObject()
	: define("toBeHalf", |this, expectedValue| {
		  require(this: actualValue(): equals(expectedValue/2), this: actualValue() + " isn't half " + expectedValue)
		  println(" OK: " + this: actualValue() + " is half " + expectedValue)
	  })

function integerMatcher = -> DynamicObject()
	: define("toBeInteger", |this| {
			require(this: actualValue() oftype Integer.class, this: actualValue() + " is not an Integer")
			println(" OK: " + this: actualValue() + " is an Integer")
		})