require 'spy/instance/filters/when'
require 'spy/instance/filters/wrap'
require 'spy/instance/strategy'

# An instance of a spied method
# - Holds a reference to the original method
# - Wraps the original method
# - Provides hooks for callbacks
module Spy
  class Instance
    # TODO: Do we still need all of these to be public?
    attr_reader :original, :spied, :strategy, :call_count, :visibility

    def initialize(spied, original)
      @spied = spied
      @original = original
      @visibility = extract_visibility
      @before_filters = []
      @around_filters = []
      @call_count = 0
      @strategy = Strategy.factory_build(self)
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
        add_before_filter Filters::When.new(block)
      end

      def wrap(&block)
        add_around_filter Filters::Wrap.new(block)
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
        before_call(*args)
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

    def before_call(*args)
      @call_count += 1 if @before_filters.all? {|f| f.before_call(*args)}
    end

    def around_call(*args)
      @around_filters.each {|f| f.around_call(*args)}
    end

    def add_before_filter(filter)
      @before_filters << filter
      self
    end

    def add_around_filter(filter)
      @around_filters << filter
      self
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
