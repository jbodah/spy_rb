require 'test_helper'

class ClassTest < Minitest::Spec
  it 'works' do
    klass = Class.new(Object)
    klass.class_eval do
      def name; "penny"; end
      def say_hi(name); "hi #{name}"; end
    end
    multi = Spy.on_class(klass)
    assert multi.call_count == 0
    obj = klass.new
    obj.name
    assert_equal "hi josh", obj.say_hi("josh")
    assert_equal 2, multi.call_count
    assert_equal 1, multi[:name].call_count
    assert_equal 1, multi[:say_hi].call_count
  end
end
