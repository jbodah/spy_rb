require 'spy/errors'
require 'spy/registry/store'
require 'spy/registry/entry'

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
      entry = Entry.new(spied, method, spy)
      if store.include? entry
        raise Errors::AlreadySpiedError
      end
      store.insert(entry)
    end

    # Stops tracking the spy
    #
    # @param [Object] spied - the object being spied on
    # @param [Method, UnboundMethod] method - the method being spied on
    # @raises [Spy::Errors::MethodNotSpiedError] if the spy isn't being tracked
    def remove(spied, method)
      entry = Entry.new(spied, method, nil)
      if !store.include? entry
        raise Errors::MethodNotSpiedError
      end
      store.remove(entry).spy
    end

    # Stops tracking all spies
    #
    # @raises [Spy::Errors::UnableToEmptySpyRegistryError] if any spies were
    #   still being tracked after removing all of the spies
    def remove_all
      store.map {|e| yield remove(e.spied, e.method)}
      if !store.empty?
        raise Errors::UnableToEmptySpyRegistryError
      end
    end

    # Returns whether or not the object and method are already being spied on
    #
    # @returns [Boolean] whether or not the object and method are already being
    #   spied on
    def include?(spied, method)
      entry = Entry.new(spied, method)
      store.include? entry
    end

    private

    def store
      @store ||= Store.new
    end
  end
end
