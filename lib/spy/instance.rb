require 'spy/callbacks/with_args'
require 'spy/callbacks/when'

# An instance of a spied method
# - Holds a reference to the original method
# - Wraps the original method
# - Provides hooks for callbacks
module Spy
  class Instance
    attr_reader :receiver, :method_type, :msg, :original, :call_count, :visibility

    def initialize(receiver, msg, method_type)
      @msg = msg
      @receiver = receiver
      @method_type = method_type
      @before_filters = []
      @call_count = 0

      # Cache the original method for unwrapping later
      @original = @receiver.send(method_type, msg)
      @visibility = extract_visibility
    end

    def start
      context = self
      original.owner.instance_eval do
        define_method context.msg do |*args|
          context.before_call(*args)
          if context.original.respond_to? :bind
            result = context.original.bind(self).call(*args)
          else
            result = context.original.call(*args)
          end
          result
        end
        send(context.visibility, context.msg)
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

    def before_call(*args)
      @call_count += 1 if @before_filters.all? {|f| f.before_call(*args)}
    end

    def with_args(*args)
      add_before_filter Callbacks::WithArgs.new(*args)
    end

    def when(&block)
      add_before_filter Callbacks::When.new(block)
    end

    private

    def add_before_filter(filter)
      @before_filters << filter
      self
    end

    def extract_visibility
      owner = @original.owner
      [:public, :protected, :private].each do |vis|
        query = "#{vis}_method_defined?"
        if owner.respond_to?(query) && owner.send(query, @msg)
          return vis
        end
      end
      raise NoMethodError, "couldn't find method #{@msg} belonging to #{owner}"
    end
  end
end
