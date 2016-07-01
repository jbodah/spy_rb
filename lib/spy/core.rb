require 'spy/instance'
require 'spy/collection'
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
      if collection.include?(object, method)
        raise Errors::AlreadySpiedError
      end
      spy = Instance.new(object, method)
      collection.insert(object, method, spy)
      spy.start
    end

    # Stop spying on the given object and method
    #
    # @param [Object] object - the object being spied on
    # @param [Method, UnboundMethod] method - the method to stop spying on
    # @raises [Spy::Errors::MethodNotSpiedError] if the method is not already
    #   being spied on
    def remove_spy(object, method)
      spy = collection.remove(object, method)
      spy.stop
    end

    # Stops spying on all objects and methods
    #
    # @raises [Spy::Errors::UnableToEmptySpyCollectionError] if for some reason
    #   a spy was not removed
    def remove_all_spies
      collection.remove_all { |spy| spy.stop }
    end

    private

    def collection
      @collection ||= Collection.new
    end
  end
end
