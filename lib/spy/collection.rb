require 'spy/errors'
require 'spy/collection/store'
require 'spy/collection/entry'

module Spy
  # Responsible for error handling and mapping to Entry
  class Collection
    def insert(spied, method, spy)
      entry = Entry.new(spied, method, spy)
      if store.include? entry
        raise Errors::AlreadySpiedError
      end
      store.insert(entry)
    end

    def remove(spied, method)
      entry = Entry.new(spied, method, nil)
      if !store.include? entry
        raise Errors::MethodNotSpiedError
      end
      store.remove(entry).spy
    end

    def remove_all
      store.map {|e| yield remove(e.spied, e.method)}
      if !store.empty?
        raise Errors::UnableToEmptySpyCollectionError
      end
    end

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
