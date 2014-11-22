# An instance of a spied method
# - Holds a reference to the original method
# - Wraps the original method
# - Provides hooks for callbacks
module Spy
  class Instance
    attr_reader :msg, :original, :call_count

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
      context = self
      @original.owner.instance_eval do
        define_method context.msg do |*args|
          context.wrapped *args
        end
      end
    end

    def unwrap_original
      context = self
      @original.owner.instance_eval do
        define_method context.msg, context.original
      end
    end

    def wrapped(*args)
      result = @original.call(*args)
      after_call(result, *args)
      result
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
