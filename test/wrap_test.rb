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

    def recursive_add(original, n)
      return original if n == 0
      recursive_add(original, n - 1) + 1
    end
  end

  describe 'Spy::Instance#wrap' do
    describe 'followed by the method call' do
      it 'correctly wraps the call based on the block.call placement' do
        # yield before
        spied = TestClass.new
        spy = Spy.on(spied, :append)
        spy.wrap do |&block|
          spied.string << 'a'
          block.call
        end

        spied.append('b')

        assert_equal 'ab', spied.string,
          'expected wrapping block code to be called before block.call'

        # yield after
        spied = TestClass.new
        spy = Spy.on(spied, :append)
        spy.wrap do |&block|
          block.call
          spied.string << 'a'
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

      it 'returns the original result' do
        obj = Object.new.tap do |o|
          o.instance_eval do
            def hello
              'hello'
            end
          end
        end

        s = Spy.on(obj, :hello)
        s.wrap do |&block|
          123
          block.call
          456
        end

        assert_equal 'hello', obj.hello
      end

      it 'passes the receiver and the args to the wrap block' do
        obj = Object.new.tap {|o| o.instance_eval { def say(*args); end }}
        s = Spy.on(obj, :say)
        passed_args = [1, 2, 3]
        s.wrap do |reciever, *args|
          assert_equal obj, reciever
          assert_equal passed_args, args
        end
        obj.say(*passed_args)
      end

      it 'works with recursive methods' do
        r = TestClass.new
        spy = Spy.on(r, :recursive_add)

        spy.wrap do |*args, &block|
          block.call
        end
        assert_equal 4, r.recursive_add(2,2)
      end
    end
  end
end
