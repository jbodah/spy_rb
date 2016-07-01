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
    # Start spying on the given object and method
    #
    # @param [Object] object - the object to spy on
    # @param [Method, UnboundMethod] method - the method to spy on
    # @returns [Spy::Instance]
    # @raises [Spy::Errors::AlreadySpiedError] if the method is already
    #   being spied on
    def add_spy(object, method)
      raise Errors::AlreadySpiedError if registry.include?(object, method)
      spy = Instance.new(object, method)
      registry.insert(object, method, spy)
      spy.start
    end

    # Stop spying on the given object and method
    #
    # @param [Object] object - the object being spied on
    # @param [Method, UnboundMethod] method - the method to stop spying on
    # @raises [Spy::Errors::MethodNotSpiedError] if the method is not already
    #   being spied on
    def remove_spy(object, method)
      spy = registry.remove(object, method)
      spy.stop
    end

    # Stops spying on all objects and methods
    #
    # @raises [Spy::Errors::UnableToEmptySpyRegistryError] if for some reason
    #   a spy was not removed
    def remove_all_spies
      registry.remove_all { |spy| spy.stop }
    end

    private

    def registry
      @registry ||= Registry.new
    end
  end
end
