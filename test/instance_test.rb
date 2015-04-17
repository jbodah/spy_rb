require 'test_helper'

class InstanceTest < Minitest::Spec
  class TestClass
    attr_accessor :string

    def initialize
      @string = ''
    end

    def append(char)
      @string << char
    end
  end

  describe '#wrap' do
    describe 'followed by the method call' do
      it 'correctly wraps the call based on the yield placement' do
        # yield before
        spied = TestClass.new
        spy = Spy.on(spied, :append)
        spy.wrap do |context|
          context.string << 'a'
          yield
        end

        spied.append('b')

        assert_equal 'ab', spied.string, 'expected wrapping block code to be called before yield'

        # yield after
        spied = TestClass.new
        spy = Spy.on(spied, :append)
        spy.wrap do |context|
          yield
          context.string << 'a'
        end

        spied.append('b')

        assert_equal 'ba', spied.string, 'exptected wrapping block code to be called after yield'
      end

      it 'still updates the call count properly even with multiple wraps' do
        spied = TestClass.new
        spy = Spy.on(spied, :append)
        2.times { spy.wrap { yield } }
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
