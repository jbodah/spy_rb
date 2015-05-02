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
      @around_procs = []
      @call_count = 0
      @call_history = []
      @strategy = Strategy.factory_build(self)
    end

    class MethodCall
      attr_reader :context, :args
      attr_accessor :result

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

      # Expect block to yield. Call the rest of the chain
      # when it does
      def wrap(&block)
        @around_procs << block
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
        end

        if @around_procs.any?
          # Procify the original call
          original_proc = Proc.new do
            record = track_call(context, *args) if is_active
            result = call_original(context, *args)
            record.result = result if is_active
          end

          # Keep wrapping the original proc with each around_proc
          @around_procs.reduce(original_proc) do |p, wrapper|
            Proc.new { wrapper.call context, *args, &p }
          end.call
        else
          record = track_call(context, *args) if is_active
          result = call_original(context, *args)
          record.result = result if is_active
        end

        if is_active
          @after_callbacks.each {|f| f.call(*args)}
        end

        result
      end

      private

      def track_call(context, *args)
        @call_count += 1
        record = MethodCall.new(context, *args)
        @call_history << record
        record
      end

      def call_original(context, *args)
        if original.is_a?(UnboundMethod)
          original.bind(context).call(*args)
        else
          original.call(*args)
        end
      end
    end

    include InternalAPI
    include ExternalAPI

    private

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
