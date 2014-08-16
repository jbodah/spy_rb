require 'minitest/spec'
require 'minitest/autorun'
require_relative '../lib/spy'

class FakeClass
  def initialize(value)
    @value = value
  end

  def value
    @value
  end

  def self.hello_world
    'hello world'
  end
end

class SpyTest < MiniTest::Spec
  describe Spy do
    describe ".unspy_instance_method" do
      it "should remove the spy" do
        skip 'todo'
        count = 0
        Spy.on_instance_method(FakeClass, :value) { count += 1 }
        Spy.unspy_instance_method(FakeClass, :value)
        fake = FakeClass.new(6)
        count.must_equal 0
      end
    end

    describe ".unspy_class_method" do
      it "should remove the spy" do
        skip 'todo'
        count = 0
        Spy.on_class_method(FakeClass, :hello_world) { count += 1 }
        Spy.unspy_class_method(FakeClass, :hello_world)
        FakeClass.hello
        count.must_equal 0
      end
    end
    
    describe ".on_instance_method" do
      it "accepts a block which is run when the spied method is called" do
        count = 0
        Spy.on_instance_method(FakeClass, :value) { count += 1 }
        fake = FakeClass.new(6)
        fake.value
        count.must_equal 1
      end

      it "should still call the spied method" do
        Spy.on_instance_method(FakeClass, :value)
        fake = FakeClass.new(6)
        fake.value.must_equal 6
      end

      it "should raise an exception if the method is undefined" do
        skip 'todo'
      end

      it "should support multiple arguments" do
        skip 'todo'
      end
    end

    describe ".on_class_method" do
      it "accepts a block which is run when the spied method is called" do
        count = 0
        Spy.on_class_method(FakeClass, :hello_world) { count += 1 }
        FakeClass.hello_world
        count.must_equal 1
      end

      it "should still call the spied method" do
        Spy.on_class_method(FakeClass, :hello_world)
        FakeClass.hello_world.must_equal 'hello world'
      end

      it "should raise an exception if the method is undefined" do
        skip 'todo'
      end

      it "should support multiple arguments" do
        skip 'todo'
      end
    end
  end
end
