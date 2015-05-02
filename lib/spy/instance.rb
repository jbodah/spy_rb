require 'spy/instance/strategy'

# An instance of a spied method
# - Holds a reference to the original method
# - Wraps the original method
# - Provides hooks for callbacks
module Spy
  class Instance
    attr_reader :original, :spied, :strategy, :call_count, :visibility, :call_history

    def initialize(spied, original)
      @spied = spied
      @original = original
      @visibility = extract_visibility
      @conditional_filters = []
      @before_callbacks = []
      @after_callbacks = []
      @call_count = 0
      @call_history = []
      @strategy = Strategy.factory_build(self)
    end

    class MethodCall
      attr_reader :context, :args

      def initialize(context, *args)
        @context = context
        @args = args
      end
    end

    # The API we expose to consumers. This is the module you'll
    # want to look at 90% of the time
    module ExternalAPI
      def start
        @strategy.apply
        self
      end

      def stop
        @strategy.undo
        self
      end

      def when(&block)
        @conditional_filters << block
        self
      end

      def before(&block)
        @before_callbacks << block
        self
      end

      def after(&block)
        @after_callbacks << block
        self
      end
    end

    # The API we expose internally to our collaborators
    module InternalAPI
      # TODO: Not sure if this is the best place for this
      #
      # Defines the spy on the target object
      def attach_to(target)
        spy = self
        target.class_eval do
          define_method spy.original.name do |*args|
            spy.call(self, *args)
          end
          send(spy.visibility, spy.original.name)
        end
      end

      # Call the spied method using the given context and arguments.
      #
      # Context is required for calling UnboundMethods such as
      # instance methods defined on a Class
      def call(context, *args)
        is_active = @conditional_filters.all? {|f| f.call(*args)}

        if is_active
          @before_callbacks.each {|f| f.call(*args)}
          @call_count += 1
          @call_history << MethodCall.new(context, *args)
        end

        result = call_original(context, *args)

        if is_active
          @after_callbacks.each {|f| f.call(*args)}
        end

        result
      end
    end

    include InternalAPI
    include ExternalAPI

    private

    def call_original(context, *args)
      if original.is_a?(UnboundMethod)
        original.bind(context).call(*args)
      else
        original.call(*args)
      end
    end

    def extract_visibility
      owner = @original.owner
      [:public, :protected, :private].each do |vis|
        query = "#{vis}_method_defined?"
        if owner.respond_to?(query) && owner.send(query, @original.name)
          return vis
        end
      end
      raise NoMethodError, "couldn't find method #{@original.name} belonging to #{owner}"
    end
  end
end
