require 'test_helper'

class CallHistoryTest < Minitest::Spec
  describe 'Spy#call_history' do
    it 'is empty when no calls have been made' do
      arr = Array.new
      spy = Spy.on(arr, :<<)
      assert spy.call_history.empty?
    end

    it 'has a single item when one call has been made' do
      arr = Array.new
      spy = Spy.on(arr, :<<)
      arr << 'a'
      assert_equal 1, spy.call_history.size
    end

    it 'has two items, ordered from first call to last, when two calls have been made' do
      arr = Array.new
      spy = Spy.on(arr, :<<)
      arr << 'a'
      arr << 'b'
      assert_equal 2,     spy.call_history.size
      assert_equal arr,   spy.call_history[0].receiver
      assert_equal ['a'], spy.call_history[0].args
      assert_equal arr,   spy.call_history[1].receiver
      assert_equal ['b'], spy.call_history[1].args
    end

    it 'contains the result' do
      obj = Object.new
      obj.instance_eval { define_singleton_method :add, Proc.new { |a,b| a + b }}
      spy = Spy.on(obj, :add)
      obj.add(2, 2)
      obj.add(3, 3)
      assert_equal 2, spy.call_history.size
      assert_equal 4, spy.call_history[0].result
      assert_equal 6, spy.call_history[1].result
    end
  end
end
