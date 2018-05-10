require 'spy/fake_method'
require 'spy/strategy/wrap'
require 'spy/strategy/intercept'

# An instance of a spied method
# - Holds a reference to the original method
# - Wraps the original method
# - Provides hooks for callbacks
module Spy
  class Instance
    attr_reader :original, :spied, :strategy, :call_history

    def initialize(blueprint)
      original =
        case blueprint.type
        when :dynamic_delegation
          FakeMethod.new(blueprint.msg) { |*args, &block| blueprint.target.method_missing(blueprint.msg, *args, &block) }
        when :instance_method
          blueprint.target.instance_method(blueprint.msg)
        else
          blueprint.target.method(blueprint.msg)
        end

      @original = original
      @spied = blueprint.target
      @strategy = choose_strategy(blueprint)
      @call_history = []

      @internal = {}
      @internal[:conditional_filters] = []
      @internal[:before_callbacks] = []
      @internal[:after_callbacks]= []
      @internal[:around_procs] = []
      @internal[:instead]= nil
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
      @internal[:conditional_filters] << block
      self
    end

    # Expect block to yield. Call the rest of the chain
    # when it does
    def wrap(&block)
      @internal[:around_procs] << block
      self
    end

    def before(&block)
      @internal[:before_callbacks] << block
      self
    end

    def after(&block)
      @internal[:after_callbacks] << block
      self
    end

    def instead(&block)
      @internal[:instead] = block
      self
    end

    private

    def choose_strategy(blueprint)
      if blueprint.type == :dynamic_delegation
        Strategy::Intercept.new(self)
      elsif @original.owner == @spied || @original.owner == @spied.singleton_class
        Strategy::Wrap.new(self)
      else
        Strategy::Intercept.new(self)
      end
    end
  end
end
