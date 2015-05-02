require 'test_helper'

class BeforeAfterTest < Minitest::Spec
  describe 'Spy#before' do
    it 'is called before the original method' do
      arr = []
      spy = Spy.on(arr, :<<)
      spy.before { arr.push('b') }
      arr << 'a'
      assert_equal ['b', 'a'], arr
    end

    it 'is passed the the args of the call' do
      arr = []
      spy = Spy.on(arr, :<<)
      called_args = nil
      spy.before {|*args| called_args = *args}
      arr << 'a'
      assert_equal ['a'], called_args
    end
  end

  describe 'Spy#after' do
    it 'is called after the original method' do
      arr = []
      spy = Spy.on(arr, :<<)
      spy.after { arr.push('b') }
      arr << 'a'
      assert_equal ['a', 'b'], arr
    end

    it 'is passed the the args of the call' do
      arr = []
      spy = Spy.on(arr, :<<)
      called_args = nil
      spy.after {|*args| called_args = *args}
      arr << 'a'
      assert_equal ['a'], called_args
    end
  end
end
