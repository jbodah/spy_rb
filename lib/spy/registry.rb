require 'spy/errors'
require 'spy/registry_store'
require 'spy/registry_entry'

module Spy
  # Responsible for managing the top-level state of which spies exist.
  class Registry
    # Keeps track of the spy for later management. Ensures spy uniqueness
    #
    # @param [Object] spied - the object being spied on
    # @param [Method, UnboundMethod] method - the method being spied on
    # @param [Spy::Instance] spy - the instantiated spy
    # @raises [Spy::Errors::AlreadySpiedError] if the spy is already being
    #   tracked
    def insert(spied, method, spy)
      entry = RegistryEntry.new(spied, method, spy)
      raise Errors::AlreadySpiedError if store.include? entry
      store.insert(entry)
    end

    # Stops tracking the spy
    #
    # @param [Object] spied - the object being spied on
    # @param [Method, UnboundMethod] method - the method being spied on
    # @raises [Spy::Errors::MethodNotSpiedError] if the spy isn't being tracked
    def remove(spied, method)
      entry = RegistryEntry.new(spied, method, nil)
      raise Errors::MethodNotSpiedError unless store.include? entry
      store.remove(entry).spy
    end

    # Stops tracking all spies
    #
    # @raises [Spy::Errors::UnableToEmptySpyRegistryError] if any spies were
    #   still being tracked after removing all of the spies
    def remove_all
      store.map { |e| yield remove(e.spied, e.method) }
      raise Errors::UnableToEmptySpyRegistryError unless store.empty?
    end

    # Returns whether or not the object and method are already being spied on
    #
    # @returns [Boolean] whether or not the object and method are already being
    #   spied on
    def include?(spied, method)
      entry = RegistryEntry.new(spied, method)
      store.include? entry
    end

    private

    def store
      @store ||= RegistryStore.new
    end
  end
end
