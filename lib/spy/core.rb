require_relative 'instance'
require_relative 'collection'
require_relative 'errors'

module Spy
  class Core
    def spy_collection
      @spy_collection ||= Collection.new
    end

    def add_spy(receiver, msg, method_type)
      if spy_collection.contains?(receiver, msg, method_type)
        raise Errors::AlreadySpiedError
      end

      value = Instance.new(receiver, msg, method_type)
      spy_collection.insert(receiver, msg, method_type, value)
    end

    def remove_spy(receiver, msg, method_type)
      unless receiver.send("#{method_type}s".to_sym).include? msg
        raise NoMethodError
      end

      spy_collection.remove(receiver, msg, method_type).destroy
    end

    def remove_all_spies
      spy_collection.remove_all do |value|
        value.destroy
      end
    end
  end
end
