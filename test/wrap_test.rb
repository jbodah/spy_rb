require 'test_helper'

class WrapTest < Minitest::Spec
  class TestClass
    attr_accessor :string

    def initialize
      @string = ''
    end

    def append(char)
      @string << char
    end
  end

  describe 'Spy#wrap' do
    describe 'followed by the method call' do
      it 'correctly wraps the call based on the block.call placement' do
        # yield before
        spied = TestClass.new
        spy = Spy.on(spied, :append)
        spy.wrap do |receiver, &block|
          receiver.string << 'a'
          block.call
        end

        spied.append('b')

        assert_equal 'ab', spied.string,
          'expected wrapping block code to be called before block.call'

        # yield after
        spied = TestClass.new
        spy = Spy.on(spied, :append)
        spy.wrap do |receiver, &block|
          block.call
          receiver.string << 'a'
        end

        spied.append('b')

        assert_equal 'ba', spied.string,
          'expected wrapping block code to be called after block.call'
      end

      it 'still updates the call count properly even with multiple wraps' do
        spied = TestClass.new
        spy = Spy.on(spied, :append)
        2.times { spy.wrap { |&block| block.call }}
        spied.append 'a'
        assert_equal 1, spy.call_count
      end

      it 'only updates the call count when the actual original call is made' do
        spied = TestClass.new
        spy = Spy.on(spied, :append)
        spy.wrap {}
        spied.append('b')
        assert_equal 0, spy.call_count
      end
    end
  end
end
