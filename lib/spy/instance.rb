require 'spy/callbacks/with_args'

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
      @filters = []
      @call_count = 0

      # Cache the original method for unwrapping later
      @original = @receiver.send(method_type, msg)
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
          context.on_call(result, *args)
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

    def on_call(result, *args)
      @call_count += 1 if @filters.all? {|f| f.call(result, *args)}
    end

    def with_args(*args)
      add_filter Callbacks::WithArgs.new(*args)
    end

    private

    def add_filter(filter)
      @filters << filter
      self
    end
  end
end
