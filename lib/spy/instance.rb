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

    def called?
      @call_history.any?
    end

    # @private
    def call_original(*args)
      if original.is_a?(UnboundMethod)
        call_original_unbound_method(*args)
      else
        call_original_method(*args)
      end
    end

    # @private
    def apply(method_call)
      return method_call.call_original unless passes_all_conditions?(method_call)

      run_before_callbacks(method_call)

      result = nil
      runner =
        if @internal[:instead]
          proc do
            @call_history << method_call
            result = @internal[:instead].call(method_call)
          end
        else
          proc do
            @call_history << method_call
            result = method_call.call_original(true)
          end
        end

      if @internal[:around_procs].any?
        runner = @internal[:around_procs].reduce(runner) do |p, wrapper|
          proc { wrapper[method_call, &p] }
        end
      end

      runner.call

      run_after_callbacks(method_call)

      result
    end

    private

    def passes_all_conditions?(method_call)
      @internal[:conditional_filters].all? { |f| f[method_call] }
    end

    def run_before_callbacks(method_call)
      @internal[:before_callbacks].each { |f| f[method_call] }
    end

    def run_after_callbacks(method_call)
      @internal[:after_callbacks].each { |f| f[method_call] }
    end

    def call_original_unbound_method(receiver, args, block)
      original.bind(receiver).call(*args, &block)
    end

    def call_original_method(_receiver, args, block)
      original.call(*args, &block)
    end

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
