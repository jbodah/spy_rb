require 'spy/instance'
require 'spy/registry'
require 'spy/multi'
require 'spy/errors'

module Spy
  # The main internal API. This is used directly by `Spy::API` and
  # is the primary control center for creating and removing spies.
  #
  # Syntactic sugar (like `Spy.restore(object, msg)` vs `Spy.restore(:all)`)
  # should be handled in `Spy::API` and utilize `Spy::Core`
  class Core
    UNSAFE_METHODS = [:object_id, :__send__, :__id__, :method, :singleton_class]

    def initialize
      @registry = Registry.new
    end

    # Start spying on the given object and method
    #
    # @param [Spy::Blueprint] blueprint - data for building the spy
    # @returns [Spy::Instance]
    # @raises [Spy::Errors::AlreadySpiedError] if the method is already
    #   being spied on
    def add_spy(blueprint)
      if prev = @registry.get(blueprint)
        raise Errors::AlreadySpiedError.new("Already spied on here:\n\t#{prev[0].caller.join("\n\t")}")
      end
      spy = Instance.new(blueprint)
      @registry.insert(blueprint, spy)
      spy.start
    end

    # Start spying on all of the given objects and methods
    #
    # @param [Spy::Blueprint] blueprint - data for building the spy
    # @returns [Spy::Multi]
    def add_multi_spy(multi_blueprint)
      target = multi_blueprint.target
      type = multi_blueprint.type
      methods = target.public_send(type).reject(&method(:unsafe_method?))
      spies = methods.map do |method_name|
        singular_type = type.to_s.sub(/s$/, '').to_sym
        add_spy(Blueprint.new(multi_blueprint.target, method_name, singular_type))
      end
      Multi.new(spies)
    end

    # Stop spying on the given object and method
    #
    # @raises [Spy::Errors::MethodNotSpiedError] if the method is not already
    #   being spied on
    def remove_spy(blueprint)
      spy = @registry.remove(blueprint)
      spy.stop
    end

    # Stops spying on all objects and methods
    def remove_all_spies
      @registry.remove_all.each(&:stop)
    end

    private

    def unsafe_method?(name)
      UNSAFE_METHODS.include?(name)
    end
  end
end
