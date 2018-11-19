require 'test_helper'

class BlockTest < Minitest::Spec
  it 'can yield a new argument to the block' do
    obj = Object.new
    obj.instance_eval do
      def yield_a
        yield "a"
      end
    end
    Spy.on(obj, :yield_a).instead { |method_call| method_call.block.call("b") }
    assert_equal "bbb", obj.yield_a { |a| a * 3 }
  end
end
