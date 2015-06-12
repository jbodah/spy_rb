require 'spy/instance'
require 'spy/collection'
require 'spy/errors'

module Spy
  class Core
    def add_spy(spied, method)
      if collection.include?(spied, method)
        raise Errors::AlreadySpiedError
      end
      spy = Instance.new(spied, method)
      collection.insert(spied, method, spy)
      spy.start
    end

    def remove_spy(spied, method)
      spy = collection.remove(spied, method)
      spy.stop
    end

    def remove_all_spies
      collection.remove_all { |spy| spy.stop }
    end

    private

    def collection
      @collection ||= Collection.new
    end
  end
end
