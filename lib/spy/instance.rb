require 'spy/instance/strategy'
require 'spy/instance/api/internal'

# An instance of a spied method
# - Holds a reference to the original method
# - Wraps the original method
# - Provides hooks for callbacks
module Spy
  class Instance
    include API::Internal

    attr_reader :original, :spied, :strategy, :visibility, :call_history

    def initialize(spied, original)
      @spied = spied
      @original = original
      @visibility = extract_visibility
      @conditional_filters = []
      @before_callbacks = []
      @after_callbacks = []
      @around_procs = []
      @call_history = []
      @strategy = Strategy.factory_build(self)
      @instead = nil
    end

    def name
      @original.name
    end

    def call_count
      @call_history.size
    end

    def replay_all
      @call_history.map(&:replay)
    end

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

    def instead(&block)
      @instead = block
    end

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
