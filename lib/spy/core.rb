require 'spy/instance'
require 'spy/collection'
require 'spy/errors'

module Spy
  class Core
    def spy_collection
      @spy_collection ||= Collection.new
    end

    def add_spy(spied, method)
      spy = Instance.new(spied, method)
      spy_collection << spy
      spy.start
    end

    def remove_spy(spied, method)
      spy = spy_collection.pop(method)
      spy.stop
    end

    def remove_all_spies
      spy_collection.remove_all { |spy| spy.stop }
    end
  end
end
