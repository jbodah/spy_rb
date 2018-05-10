require 'spy/errors'

module Spy
  # Responsible for managing the top-level state of which spies exist.
  class Registry
    def initialize
      @store = {}
    end

    # Keeps track of the spy for later management. Ensures spy uniqueness
    #
    # @param [Spy::Blueprint]
    # @param [Spy::Instance] spy - the instantiated spy
    # @raises [Spy::Errors::AlreadySpiedError] if the spy is already being
    #   tracked
    def insert(blueprint, spy)
      key = blueprint.to_s
      raise Errors::AlreadySpiedError if @store[key]
      @store[key] = [blueprint, spy]
    end

    # Stops tracking the spy
    #
    # @param [Spy::Blueprint]
    # @raises [Spy::Errors::MethodNotSpiedError] if the spy isn't being tracked
    def remove(blueprint)
      key = blueprint.to_s
      raise Errors::MethodNotSpiedError unless @store[key]
      @store.delete(key)[1]
    end

    # Stops tracking all spies
    def remove_all
      store = @store
      @store = {}
      store.values.map(&:last)
    end

    def get(blueprint)
      key = blueprint.to_s
      @store[key]
    end
  end
end
