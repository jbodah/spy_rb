require 'test_helper'

class CallHistoryTest < Minitest::Spec
  describe 'Spy::Instance#call_history' do
    it 'is empty when no calls have been made' do
      arr = []
      spy = Spy.on(arr, :<<)
      assert spy.call_history.empty?
    end

    it 'has a single item when one call has been made' do
      arr = []
      spy = Spy.on(arr, :<<)
      arr << 'a'
      assert_equal 1, spy.call_history.size
    end

    it 'has two items, ordered from first call to last, when two calls have been made' do
      arr = []
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
      obj.instance_eval { define_singleton_method :add, Proc.new { |a, b| a + b } }
      spy = Spy.on(obj, :add)
      obj.add(2, 2)
      obj.add(3, 3)
      assert_equal 2, spy.call_history.size
      assert_equal 4, spy.call_history[0].result
      assert_equal 6, spy.call_history[1].result
    end

    it 'records any block that the call was passed (on captured blocks)' do
      obj = Object.new
      obj.instance_eval do
        def perform(&block)
          block.call
        end
      end
      spy = Spy.on(obj, :perform)

      sum = 0
      obj.perform { sum += 1 }
      assert_equal sum, 1, 'expected proc to be called on spied method'
      spy.call_history[0].block.call
      assert_equal sum, 2, 'expected Spy::MethodCall#block.call to call original block'
    end

    it 'records any block that the call was passed (on yielded blocks)' do
      obj = Object.new
      obj.instance_eval do
        def perform
          yield
        end
      end
      spy = Spy.on(obj, :perform)

      sum = 0
      obj.perform { sum += 1 }
      assert_equal sum, 1, 'expected proc to be called on spied method'
      spy.call_history[0].block.call
      assert_equal sum, 2, 'expected Spy::MethodCall#block.call to call original block'
    end

    it 'records the method name' do
      obj = Object.new
      obj.instance_eval { define_singleton_method :perform, Proc.new {} }
      spy = Spy.on(obj, :perform)
      obj.perform
      assert_equal :perform, spy.call_history[0].name
    end
  end
end
