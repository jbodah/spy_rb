require 'spy/instance'
require 'spy/registry'
require 'spy/errors'

module Spy
  # The main internal API. This is used directly by `Spy::API` and
  # is the primary control center for creating and removing spies.
  #
  # Syntactic sugar (like `Spy.restore(object, msg)` vs `Spy.restore(:all)`)
  # should be handled in `Spy::API` and utilize `Spy::Core`
  class Core
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
  end
end
