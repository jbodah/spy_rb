# An instance of a spied method
# - Holds a reference to the original method
# - Wraps the original method
# - Provides hooks for callbacks
module Spy
  class Instance
    attr_reader :msg, :call_count

    def initialize(msg, original)
      @msg = msg
      @original = original
      @call_count = 0
      @match_args = []
      wrap_original
    end

    def destroy
      unwrap_original
    end

    def wrap_original
      msg = @msg
      original = @original
      after_call = Proc.new {|result, *args| after_call(result, *args)}
      original.owner.instance_eval do
        define_method msg do |*args|
          result = original.call(*args)
          after_call.call(result, *args)
          result
        end
      end
    end

    def unwrap_original
      msg = @msg
      original = @original
      @original.owner.instance_eval { define_method msg, original }
    end

    def after_call(result, *args)
      return unless @match_args.empty? || @match_args == args
      @call_count += 1
    end

    def with_args(*args)
      @match_args = args || []
      self
    end
  end
end
