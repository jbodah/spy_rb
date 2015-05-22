# Spy

[![Travis Status](https://travis-ci.org/jbodah/spy_rb.svg?branch=master)](https://travis-ci.org/jbodah/spy_rb)
[![Coverage Status](https://coveralls.io/repos/jbodah/spy_rb/badge.svg?branch=master)](https://coveralls.io/r/jbodah/spy_rb?branch=master)
[![Code Climate](https://codeclimate.com/github/jbodah/spy_rb/badges/gpa.svg)](https://codeclimate.com/github/jbodah/spy_rb)
[![Gem Version](https://badge.fury.io/rb/spy_rb.svg)](http://badge.fury.io/rb/spy_rb)

SinonJS-style Test Spies for Ruby

## Description

Spy brings everything that's great about Sinon.JS to Ruby. Mocking frameworks work by stubbing out functionality. Spy works by listening in on functionality and allowing it to run in the background. Spy is designed to be lightweight and work alongside Mocking frameworks instead of trying to replace them entirely.

## Why Spy?

* Less intrusive than mocking
* Allows you to test message passing without relying on stubbing
* Great for testing recursive methods or methods with side effects (e.g. test that something is cached and only hits the database once on the intitial call)
* Works for Ruby 1.9.3 & 2.x
* Small and simple
* Strong test coverage
* No `alias_method` pollution
* No dependencies!

## Install

```
gem install spy_rb
```

## Usage

This documentation is a work in progress. For now, please see [Spy::API](https://github.com/jbodah/spy_rb/blob/master/lib/spy/api.rb) for the full API that the `Spy` constant supports. Also take a look at [Spy::Instance](https://github.com/jbodah/spy_rb/blob/master/lib/spy/instance.rb) for the full API that an individual `Spy::Instance` (which is returned from methods like `Spy.on`) supports. 

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

## Deploying

```sh
rake full_deploy TO=0.2.1
```

## TODO
- spying on methods used by spies causes stack overflow
- more tests around any_instance
  - does restore actually work for on_any_instance??
- clean up tests around when {}, call count, exclusive spying (e.g. one instance/including class and not the other)
