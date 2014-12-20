require 'spy/callbacks/with_args'
require 'spy/callbacks/when'
require 'spy/instance/strategy'

# An instance of a spied method
# - Holds a reference to the original method
# - Wraps the original method
# - Provides hooks for callbacks
module Spy
  class Instance
    attr_reader :original, :spied, :strategy, :call_count, :visibility

    def initialize(spied, original)
      @spied = spied
      @original = original
      @visibility = extract_visibility
      @before_filters = []
      @call_count = 0
      @strategy = Strategy.factory_build(self)
    end

    def start
      @strategy.apply
      self
    end

    def stop
      @strategy.undo
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
        if owner.respond_to?(query) && owner.send(query, @original.name)
          return vis
        end
      end
      raise NoMethodError, "couldn't find method #{@original.name} belonging to #{owner}"
    end
  end
end
