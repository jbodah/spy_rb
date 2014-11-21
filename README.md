# Spy

SinonJS-style Test Spies for Ruby

## Description

Spy brings everything that's great about Sinon.JS to Ruby. Mocking frameworks work by stubbing out functionality. Spy works by listening in on functionality and allowing it to run in the background. Spy is designed to be lightweight and work alongside Mocking frameworks instead of trying to replace them entirely.

## Install

TODO: gemify + rubygems

## Usage

```ruby
require 'spy'

class TestClass
  def push(arg)
    (@array ||= []) << arg
  end
end

object = TestClass.new
spy = Spy.on(object, :push)
object.push 'hello'
puts spy.call_count
# => 1

Spy.restore(object, :push)
object.push 'goodbye'
puts spy.call_count
# => 1

object = TestClass.new
spy = Spy.on(object, :push).with_args('orange')
object.push 'apple'
puts spy.call_count
# => 0
object.push 'orange'
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
