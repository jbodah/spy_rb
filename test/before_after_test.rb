require 'test_helper'

class BeforeAfterTest < Minitest::Spec
  describe 'Spy#before' do
    it 'is called before the original method' do
      arr = []
      spy = Spy.on(arr, :<<)
      spy.before { arr.push('b') }
      arr << 'a'
      assert_equal %w(b a), arr
    end

    it 'is passed the receiver and the args of the call' do
      arr = []
      spy = Spy.on(arr, :<<)
      called_args = nil
      spy.before do |mc|
        assert_equal arr, mc.receiver
        called_args = *mc.args
      end
      arr << 'a'
      assert_equal ['a'], called_args
    end

    it 'passes a Spy::MethodCall to the block' do
      obj = []
      spy = Spy.on(obj, :<<)

      yielded = nil
      spy.before { |mc| yielded = mc }

      obj << 'hello'

      assert yielded.is_a? Spy::MethodCall
    end
  end

  describe 'Spy#after' do
    it 'is called after the original method' do
      arr = []
      spy = Spy.on(arr, :<<)
      spy.after { arr.push('b') }
      arr << 'a'
      assert_equal %w(a b), arr
    end

    it 'is passed the receiver and the args of the call' do
      arr = []
      spy = Spy.on(arr, :<<)
      called_args = nil
      spy.after do |mc|
        assert_equal arr, mc.receiver
        called_args = *mc.args
      end
      arr << 'a'
      assert_equal ['a'], called_args
    end

    it 'passes a Spy::MethodCall to the block' do
      obj = []
      spy = Spy.on(obj, :<<)

      yielded = nil
      spy.after { |mc| yielded = mc }

      obj << 'hello'

      assert yielded.is_a? Spy::MethodCall
    end

    it 'has the Spy::MethodCall result field filled in' do
      obj = []
      spy = Spy.on(obj, :<<)

      yielded = nil
      spy.after { |mc| yielded = mc }

      obj << 'hello'

      assert_equal obj, yielded.result
    end
  end
end
