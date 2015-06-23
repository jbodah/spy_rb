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

[Spy::API](https://github.com/jbodah/spy_rb/blob/master/lib/spy/api.rb) defines the top-level interface for creating spies and for interacting with them on a global scale.

You can use it to create spies in a variety of ways. For these example we'll use the `Fruit` class because, seriously, who doesn't love fruit:

```rb
class Fruit
  def eat(adj)
    puts "you take a bite #{adj}"
  end
end

require 'spy'

# Spy on singleton or bound methods
fruit = Fruit.new
s = Spy.on(fruit, :to_s)
fruit.to_s
s.call_count
#=> 1

s = Spy.on(Fruit, :to_s)
Fruit.to_s
s.call_count
#=> 1

# Spy on instance methods
s = Spy.on_any_instance(Fruit, :to_s)
apple = Fruit.new
apple.to_s
orange = Fruit.new
orange.to_s
s.call_count
#=> 2

# Spied methods respect visibility
Object.private_methods.include?(:fork)
#=> true
Spy.on(Object, :fork)
Object.fork
#=> NoMethodError: private method `fork' called for Object:Class

# Spy will let you know if you're doing something wrong too
Spy.on(Object, :doesnt_exist)
#=> NameError: undefined method `doesnt_exist' for class `Class'

Spy.on(Fruit, :to_s)
=> #<Spy::Instance:0x007feb55affe18 @spied=Fruit, @original=#<Method: Class(Module)#to_s>, @visibility=:public, @conditional_filters=[], @before_callbacks=[], @after_callbacks=[], @around_procs=[], @call_history=[], @strategy=#<Spy::Instance::Strategy::Intercept:0x007feb55affc38 @spy=#<Spy::Instance:0x007feb55affe18 ...>, @intercept_target=#<Class:Fruit>>>
Spy.on(Fruit, :to_s)
#=> Spy::Errors::AlreadySpiedError: Spy::Errors::AlreadySpiedError
```

When you're all finished you'll want to restore your methods to clean up the spies:

```rb
# Restore singleton/bound method
s = Spy.on(Object, :to_s)
Spy.restore(Object, :to_s)

# Restore instance method
s = Spy.on_any_instance(Object, :to_s)
Spy.restore(Object, :to_s, :instance)

# Global restore
s = Spy.on(Object, :to_s)
Spy.restore(:all)
```

If using in the context of a test suite, you may want to patch a `Spy.restore(:all)` into your teardowns:

Ex:
```ruby
class ActiveSupport::TestCase
  teardown do
    Spy.restore(:all)
  end
end
```

Once you've created a spy instance, then there are a variety of ways to interact with that spy. See [Spy::Instance](https://github.com/jbodah/spy_rb/tree/master/lib/spy/instance.rb) for the full list.

`Spy::Instance#call_count` will tell you how many times the spied method was called:

```rb
fruit = Fruit.new
spy = Spy.on(fruit, :eat)
fruit.eat(:slowly)
spy.call_count
#=> 1
fruit.eat(:quickly)
spy.call_count
#=> 2
```

`Spy::Instance#when` lets you spy conditionally:

```rb
fruit = Fruit.new
spy = Spy.on(fruit, :eat)
spy.when {|adj| adj == :quickly}
fruit.eat(:slowly)
spy.call_count
#=> 0
fruit.eat(:quickly)
spy.call_count
#=> 1
```

`Spy::Instance#before` and `Spy::Instance#after` give you callbacks for your spy:

```rb
fruit = Fruit.new
spy = Spy.on(fruit, :eat)
spy.before { puts 'you wash your hands' }
spy.after { puts 'you rejoice in your triumph' }
fruit.eat(:happily)
#=> you wash your hands
#=> you take a bite happily
#=> you rejoice in your triumph

# #before and #after can both accept arguments just like #when
```

`Spy::Instance#wrap` allows you to do so more complex things. Be sure to call the original block though! You don't have to worry about passing args to the original.
Those are wrapped up for you; you just need to `#call` it.

```rb
require 'benchmark'
fruit = Fruit.new
spy = Spy.on(fruit, :eat)
spy.wrap do |*args, &original|
  puts Benchmark.measure { original.call }
end
fruit.eat(:hungrily)
#=> you take a bite hungrily
#=> 0.000000   0.000000   0.000000 (  0.000039)
```

`Spy::Instance#call_history` keeps track of all of your calls for you:

```rb
fruit = Fruit.new
spy = Spy.on(fruit, :eat)
fruit.eat(:like_a_boss)
fruit.eat(:on_a_boat)
spy.call_history
#=> [
  #<Spy::MethodCall:0x007fd1db0dc6e0 @replayer=#<Proc:0x007fd1db0dc730@/Users/Bodah/.rbenv/versions/2.1.3/lib/ruby/gems/2.1.0/gems/spy_rb-0.3.0/lib/spy/instance/api/internal.rb:60>, @name=:eat, @receiver=#<Fruit:0x007fd1db0efdd0>, @args=[:like_a_boss], @result=nil>,
  #<Spy::MethodCall:0x007fd1db033c70 @replayer=#<Proc:0x007fd1db033cc0@/Users/Bodah/.rbenv/versions/2.1.3/lib/ruby/gems/2.1.0/gems/spy_rb-0.3.0/lib/spy/instance/api/internal.rb:60>, @name=:eat, @receiver=#<Fruit:0x007fd1db0efdd0>, @args=[:on_a_boat], @result=nil>
]
```

`Spy::MethodCall` has a bunch of useful methods like `#receiver`, `#args`, `#block`, `#name`, and `#result`. Right now `Spy::MethodCall` does not deep copy args or results, so be careful!

`Spy::MethodCall` also has the experimental feature `#replay`:

```rb
fruit = Fruit.new
spy = Spy.on(fruit, :eat)
fruit.eat(:quickly)
#=> you take a bite quickly
spy.call_history[0].replay
#=> you take a bite quickly
spy.call_count
#=> 1
```

Additionally, if you're adventurous you can give `Spy::Instance#replay_all` a shot:

```rb
fruit = Fruit.new
spy = Spy.on(fruit, :eat)
fruit.eat(:quickly)
#=> you take a bite quickly
fruit.eat(:slowly)
#=> you take a bite slowly
spy.call_count
#=> 2
spy.replay_all
#=> you take a bite quickly
#=> you take a bite slowly
spy.call_count
#=> 2
```

## Deploying (note to self)

```sh
rake full_deploy TO=0.2.1
```

## TODO
- spying on methods used by spies causes stack overflow
- more tests around any_instance
  - does restore actually work for on_any_instance??
- clean up tests around when {}, call count, exclusive spying (e.g. one instance/including class and not the other)
