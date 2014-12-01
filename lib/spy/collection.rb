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
        entry = Collection::Entry.new(spy.receiver, spy.msg, spy.method_type)
        entry.value = spy
        insert entry
      end

      def pop(receiver, msg, method_type)
        remove Collection::Entry.new(receiver, msg, method_type)
      end
    end

    include SpyHelper
  end
end
