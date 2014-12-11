# Spy

[![Travis Status](https://travis-ci.org/jbodah/spy_rb.svg?branch=master)](https://travis-ci.org/jbodah/spy_rb)
[![Coverage Status](https://img.shields.io/coveralls/jbodah/spy_rb.svg)](https://coveralls.io/r/jbodah/spy_rb)

SinonJS-style Test Spies for Ruby

## Description

Spy brings everything that's great about Sinon.JS to Ruby. Mocking frameworks work by stubbing out functionality. Spy works by listening in on functionality and allowing it to run in the background. Spy is designed to be lightweight and work alongside Mocking frameworks instead of trying to replace them entirely.

## Why Spy?

* Less intrusive than mocking
* Allows you to test message passing without relying on stubbing
* Works for Ruby 2.1+
* Small and simple
* Strong test coverage

## Install

```
gem install spy_rb
```

## Usage

```ruby
require 'spy'

class TestClass
  def push(arg)
    (@array ||= []) << arg
  end
end

# Spy on singleton methods
# Query for call count
object = TestClass.new
spy = Spy.on(object, :push)
object.push 'hello'
puts spy.call_count
# => 1

# Restore that method
# Call count doesn't change
Spy.restore(object, :push)
object.push 'goodbye'
puts spy.call_count
# => 1

# Use with_args to filter by args
object = TestClass.new
spy = Spy.on(object, :push).with_args('orange')
object.push 'apple'
puts spy.call_count
# => 0
object.push 'orange'
puts spy.call_count
# => 1

# Stop spying on all methods
Spy.restore(:all)

# Spy on any instance of a class
spy = Spy.on_any_instance(TestClass, :push)
a = TestClass.new
a.push 'apple'
b = TestClass.new
b.push 'orange'
puts spy.call_count
# => 2

# Restore a spied instance method
Spy.restore(TestClass, :push)

# Only increment call count when an expression returns true
a = TestClass.new
spy = Spy.on(a, :push).when {|to_push| to_push == 'apple'}
a.push 'pear'
puts spy.call_count
# => 0
a.push 'apple'
puts spy.call_count
# => 1

Spy.restore(:all)
```

If using in the context of a test suite, you may want to patch a `Spy.restore(:all)` into your teardowns:

Ex:
```ruby
ActiveSupport::TestCase.class_eval do
  teardown do
    Spy.restore(:all)
  end
end
```

## TODO
- spying on methods used by spies causes stack overflow
- does visiblity of new method match old one?
- count # of returns
- exception change call count?
- more tests around any_instance
  - does restore actually work for on_any_instance??
- record call signatures/return values
- checking return values

