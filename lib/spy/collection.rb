require 'spy/collection/entry'

module Spy
  class Collection
    include Enumerable

    def initialize
      @store = {}
    end

    def insert(entry)
      raise Errors::AlreadySpiedError if include?(entry)
      @store[entry.key] = entry
    end

    def remove(entry)
      raise Errors::MethodNotSpiedError unless include?(entry)
      @store.delete(entry.key).value
    end

    # Removes each element from the collection and calls the block
    # with each deleted element
    def remove_all
      map {|e| yield remove(e)}
    end

    def each
      @store.keys.each {|k| yield Entry.parse(k)}
    end

    # Add a slicker interface that abstracts away Collection::Entry
    module SpyHelper
      def <<(spy)
        receiver = spy.original.is_a?(Method) ? spy.original.receiver : nil
        name = spy.original.name
        klass = spy.original.class
        entry = Collection::Entry.new(receiver, name, klass)
        entry.value = spy
        insert entry
      end

      def pop(method)
        receiver = method.is_a?(Method) ? method.receiver : nil
        name = method.name
        klass = method.class
        remove Collection::Entry.new(receiver, name, klass)
      end
    end

    include SpyHelper
  end
end
