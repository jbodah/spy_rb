require 'test_helper'

class ReplayTest < Minitest::Spec
  after do
    Spy.restore(:all)
  end

  describe 'Spy::Instance#replay_all' do
    it 'replays each of the calls in sequence' do
      spy = Spy.on_any_instance(String, :<<)
      str = ''
      str << 'a'
      assert_equal 'a', str
      str << 'b'
      assert_equal 'ab', str
      spy.replay_all
      assert_equal 'abab', str
    end

    it "doesn't track replays" do
      spy = Spy.on_any_instance(String, :<<)
      str = ''
      str << 'a'
      assert_equal 'a', str
      str << 'b'
      assert_equal 'ab', str
      spy.replay_all
      assert_equal 2, spy.call_count
    end
  end

  describe 'Spy::MethodCall#replay' do
    it "doesn't track replays" do
      spy = Spy.on_any_instance(String, :<<)
      str = ''
      str << 'a'
      spy.call_history[0].replay
      assert_equal 1, spy.call_count
    end

    it 'replays a single call' do
      spy = Spy.on_any_instance(String, :<<)
      str = ''
      str << 'a'
      assert_equal 'a', str
      spy.call_history[0].replay
      assert_equal 'aa', str
    end

    it 'replays calls with the correct block (when captured)' do
      obj = Object.new
      obj.instance_eval do
        def self.block_caller(&block)
          block.call
        end
      end
      spy = Spy.on(obj, :block_caller)
      sum = 0
      obj.block_caller { sum += 1 }
      assert_equal 1, sum
      spy.call_history[0].replay
      assert_equal 2, sum
    end

    it 'replays calls with the correct block (when yielded)' do
      obj = Object.new
      obj.instance_eval do
        def self.block_caller
          yield
        end
      end
      spy = Spy.on(obj, :block_caller)
      sum = 0
      obj.block_caller { sum += 1 }
      assert_equal 1, sum
      spy.call_history[0].replay
      assert_equal 2, sum
    end
  end
end
