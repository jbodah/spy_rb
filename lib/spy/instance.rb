# An instance of a spied method
# - Holds a reference to the original method
# - Wraps the original method
# - Provides hooks for callbacks
module Spy
  class Instance
    attr_reader :receiver, :method_type, :msg, :original, :call_count

    def initialize(receiver, msg, method_type)
      @msg = msg
      @receiver = receiver
      @method_type = method_type

      # Cache the original method for unwrapping later
      @original = @receiver.send(method_type, msg)
      @call_count = 0
      @match_args = []
    end

    def start
      context = self
      original.owner.instance_eval do
        define_method context.msg do |*args|
          if context.original.respond_to? :bind
            result = context.original.bind(self).call(*args)
          else
            result = context.original.call(*args)
          end
          context.after_call(result, *args)
          result
        end
      end
      self
    end

    def stop
      context = self
      original.owner.instance_eval do
        define_method context.msg, context.original
      end
      self
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
