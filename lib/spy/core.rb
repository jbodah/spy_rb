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

      if spy_collection.contains?(spy)
        raise Errors::AlreadySpiedError
      end

      spy_collection.insert(receiver, msg, method_type, spy)
      spy.start
    end

    def remove_spy(receiver, msg, method_type)
      unless receiver.send("#{method_type}s".to_sym).include? msg
        raise NoMethodError
      end

      spy = spy_collection.remove(receiver, msg, method_type)
      spy.stop
    end

    def remove_all_spies
      spy_collection.remove_all do |spy|
        spy.stop
      end
    end
  end
end
