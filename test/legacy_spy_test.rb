require 'test_helper'

module LegacySomeModule
  def some_method
    'some_methoddd'
  end
end

class LegacyFakeClass
  include LegacySomeModule

  def age
    25
  end

  def self.hello_world
    'hello world'
  end

  def self.repeat(arg)
    arg
  end

  def self.multi_args(*args)
  end
end

class LegacySpyTest < Minitest::Spec
  describe Spy do
    after { Spy.restore :all }

    describe 'a spied method from a module' do
      it 'tracks call count' do
        obj = LegacyFakeClass.new
        spy = Spy.on(obj, :some_method)
        assert spy.call_count == 0
        obj.some_method
        assert spy.call_count == 1
      end

      it 'restores properly' do
        obj = LegacyFakeClass.new
        original = obj.method(:some_method)
        spy = Spy.on(obj, :some_method)
        assert original != obj.method(:some_method)
        Spy.restore(:all)
        assert_equal original, obj.method(:some_method)
      end

      it 'no longer tracks calls after a restore' do
        obj = LegacyFakeClass.new
        spy = Spy.on(obj, :some_method)
        obj.some_method
        assert spy.call_count == 1
        Spy.restore(:all)
        obj.some_method
        assert spy.call_count == 1
      end

      it 'only tracks the spied instance' do
        skip 'todo'
        obj = LegacyFakeClass.new
        spy = Spy.on(obj, :some_method)
        obj.some_method
        assert spy.call_count == 1
        obj2 = LegacyFakeClass.new
        obj2.some_method
        assert spy.call_count == 1
      end

      it 'tracks every instance using .on_any_instance' do
        obj = LegacyFakeClass.new
        spy = Spy.on_any_instance(LegacyFakeClass, :some_method)
        obj.some_method
        assert spy.call_count == 1
        obj2 = LegacyFakeClass.new
        obj2.some_method
        assert spy.call_count == 2
      end

      it 'properly restores using .on_any_instance' do
        original = LegacyFakeClass.instance_method(:some_method)
        spy = Spy.on_any_instance(LegacyFakeClass, :some_method)
        assert original != LegacyFakeClass.instance_method(:some_method)
        Spy.restore(:all)
        assert_equal original, LegacyFakeClass.instance_method(:some_method)
      end

      it 'no longer tracks call count when restoring using .on_any_instance' do
        obj = LegacyFakeClass.new
        spy = Spy.on_any_instance(LegacyFakeClass, :some_method)
        obj.some_method
        assert spy.call_count == 1
        Spy.restore(:all)
        obj.some_method
        assert spy.call_count == 1
      end
    end

    describe 'on_any_instance' do
      it 'allows you to spy on instances of a class' do
        spy = Spy.on_any_instance(LegacyFakeClass, :age)
        instance_a = LegacyFakeClass.new
        instance_a.age
        assert spy.call_count == 1
        instance_b = LegacyFakeClass.new
        instance_b.age
        assert spy.call_count == 2
      end

      it 'can spy on instances that have already been initialized' do
        instance = LegacyFakeClass.new
        spy = Spy.on_any_instance(LegacyFakeClass, :age)
        instance.age
        assert spy.call_count == 1
      end

      it 'throws if the instance method is already being spied' do
        Spy.on_any_instance(LegacyFakeClass, :age)
        assert_raises Spy::Errors::AlreadySpiedError do
          Spy.on_any_instance(LegacyFakeClass, :age)
        end
      end
    end

    describe '.on' do
      describe 'with no arguments' do
        it 'throws an ArgumentError' do
          assert_raises ArgumentError do
            Spy.on
          end
        end
      end

      describe 'with one argument' do
        it 'throws an ArgumentError' do
          assert_raises ArgumentError do
            Spy.on Array
          end
        end
      end

      it 'modifies the original method of an object' do
        obj = LegacyFakeClass.new
        old_method = obj.method(:age)
        Spy.on(obj, :age)
        assert obj.method(:age) != old_method
      end

      it 'modifies the class method of a class' do
        klass = LegacyFakeClass
        old_method = LegacyFakeClass.method(:hello_world)
        Spy.on(LegacyFakeClass, :hello_world)
        assert LegacyFakeClass.method(:hello_world) != old_method
      end

      it 'should not modify the spied methods return value' do
        Spy.on(LegacyFakeClass, :hello_world)
        assert LegacyFakeClass.hello_world == 'hello world'

        instance = LegacyFakeClass.new
        Spy.on(instance, :age)
        assert instance.age == 25
      end

      it 'throws if the object is missing the method to spy on' do
        assert_raises NameError do
          Spy.on(LegacyFakeClass, :this_does_not_exist)
        end
      end

      it 'throws if the method is already being spied' do
        Spy.on(LegacyFakeClass, :hello_world)
        assert_raises Spy::Errors::AlreadySpiedError do
          Spy.on(LegacyFakeClass, :hello_world)
        end
      end

      it 'returns a Spy instance' do
        assert Spy.on(LegacyFakeClass, :hello_world).is_a? Spy::Instance
      end

      it 'allows you to spy on multiple methods on the same object' do
        spy_a = Spy.on(LegacyFakeClass, :hello_world)
        spy_b = Spy.on(LegacyFakeClass, :repeat)
        LegacyFakeClass.hello_world
        assert spy_a.call_count == 1
        assert spy_b.call_count == 0
        LegacyFakeClass.repeat('test')
        assert spy_a.call_count == 1
        assert spy_b.call_count == 1
      end

      it 'leaves the method with the same visibility it had previously' do
        klass = Class.new(Object) do
          private

          def hello
            'hello'
          end
        end

        obj = klass.new
        assert obj.class.private_method_defined?(:hello)
        Spy.on(obj, :hello)
        assert obj.class.private_method_defined?(:hello)
      end
    end

    describe '.restore' do
      it 'restores all of the spied methods with the :all argument' do
        obj = LegacyFakeClass.new
        obj_method = obj.method(:age)
        klass = LegacyFakeClass
        klass_method = klass.method(:hello_world)

        Spy.on(obj, :age)
        Spy.on(klass, :hello_world)

        Spy.restore(:all)

        assert obj.method(:age) == obj_method
        assert klass.method(:hello_world) == klass_method
      end

      it 'restores the originally spied method of an object' do
        obj = LegacyFakeClass.new
        obj_method = obj.method(:age)

        Spy.on(obj, :age)

        Spy.restore(obj, :age)

        assert obj.method(:age) == obj_method
      end
      
      it 'restores singleton methods' do
        obj = LegacyFakeClass
        obj_method = LegacyFakeClass.method(:hello_world)

        Spy.on(obj, obj_method.name)
        Spy.restore(obj, obj_method.name)

        assert obj.method(obj_method.name) == obj_method
      end

      it 'throws if the method is not being spied' do
        obj = LegacyFakeClass.new
        assert_raises Spy::Errors::MethodNotSpiedError do
          Spy.restore(obj, :age)
        end
      end
    end

    describe '.with_args' do
      it 'should only count times when the args match' do
        spy = Spy.on(LegacyFakeClass, :repeat).with_args('hello')
        assert spy.call_count == 0
        LegacyFakeClass.repeat 'yo'
        assert spy.call_count == 0
        LegacyFakeClass.repeat 'hello'
        assert spy.call_count == 1
        LegacyFakeClass.repeat 'yo'
        assert spy.call_count == 1
        LegacyFakeClass.repeat 'hello'
        assert spy.call_count == 2
      end

      it 'should allow tracking of multiple arg sets' do
        skip
        spy_a = Spy.on(LegacyFakeClass, :repeat).with_args('hello')
        spy_b = Spy.on(LegacyFakeClass, :repeat).with_args('goodbye')
        LegacyFakeClass.repeat 'hello'
        assert spy_a.call_count == 1
        assert spy_b.call_count == 0
        LegacyFakeClass.repeat 'goodbye'
        assert spy_a.call_count == 1
        assert spy_b.call_count == 1
      end
    end

    describe '.call_count' do
      it 'should initially be zero' do
        spy = Spy.on(LegacyFakeClass, :hello_world)
        assert spy.call_count == 0
      end

      it 'should properly increment' do
        spy = Spy.on(LegacyFakeClass, :hello_world)
        LegacyFakeClass.hello_world
        assert spy.call_count == 1
        LegacyFakeClass.hello_world
        assert spy.call_count == 2
      end

      it 'should increment on exceptions' do
        obj = Object.new
        class << obj
          define_method :throw_exception, Proc.new { raise }
        end
        spy = Spy.on(obj, :throw_exception)
        obj.throw_exception rescue
        assert spy.call_count == 1
      end
    end

    describe '.when' do
      it 'only increments call count if the filter returns true' do
        tracking = false
        spy = Spy.on(LegacyFakeClass, :hello_world).when { tracking == true }
        LegacyFakeClass.hello_world
        assert spy.call_count == 0
        tracking = true
        LegacyFakeClass.hello_world
        assert spy.call_count == 1
      end

      it 'passes all of the call arguments to the block' do
        arg_count = 0
        Spy.on(LegacyFakeClass, :multi_args).when {|*args| arg_count = args.size}
        LegacyFakeClass.multi_args(1, 2, 3)
        assert arg_count == 3
      end

      it 'allows the user to only capture some args' do
        sum = 0
        Spy.on(LegacyFakeClass, :multi_args).when {|one, two| sum = one + two}
        LegacyFakeClass.multi_args(1, 2, 3)
        assert sum == 3
      end
    end

    describe '.then' do
      it 'calls it when the method passes all spy conditions' do
        skip
      end
    end
  end
end
