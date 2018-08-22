require 'test_helper'

class ObjectTest < Minitest::Spec
  it 'works' do
    obj = Object.new
    obj.instance_eval do
      def name; "penny"; end
      def say_hi(name); "hi #{name}"; end
    end
    multi = Spy.on_object(obj)
    calt = multi.instance_eval { @spies }.select {|x| x.call_count > 0}.map(&:name)
    assert multi.call_count == 0
    obj.name
    assert_equal "hi josh", obj.say_hi("josh")
    assert_equal 2, multi.call_count
    assert_equal 1, multi[:name].call_count
    assert_equal 1, multi[:say_hi].call_count
  end
end
