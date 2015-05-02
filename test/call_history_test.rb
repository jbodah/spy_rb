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
      assert_equal arr,   spy.call_history[0].context
      assert_equal ['a'], spy.call_history[0].args
      assert_equal arr,   spy.call_history[1].context
      assert_equal ['b'], spy.call_history[1].args
    end
  end
end
