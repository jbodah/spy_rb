require_relative 'instance'
require_relative 'collection'
require_relative 'errors'

module Spy
  class Core
    def spy_collection
      @spy_collection ||= Collection.new
    end

    def add_spy(receiver, msg, method_type)
      spy = Instance.new(receiver, msg, method_type)
      spy_collection << spy
      spy.start
    end

    def remove_spy(receiver, msg, method_type)
      spy = spy_collection.pop(receiver, msg, method_type)
      spy.stop
    end

    def remove_all_spies
      spy_collection.remove_all { |spy| spy.stop }
    end
  end
end
