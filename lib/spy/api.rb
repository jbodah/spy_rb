require_relative 'instance'
require_relative 'collection'
require_relative 'errors'

module Spy
  module API
    # Initializes a new spy instance for the method
    #
    # @param receiver - the receiver of the message you want to spy on
    # @param msg - the message passed to the receiver that you want to spy on
    def on(receiver, msg)
      add_spy(receiver, msg)
    end

    # Stops spying on the method and restores its original functionality
    #
    # @param args - supports multiple signatures
    #               
    #               Spy.restore(:all)           => stops spying on every spied message
    #               Spy.restore(receiver, msg)  => stops spying on the given receiver and message
    def restore(*args)
      if args.length == 1 && args[0] == :all
        collection.each do |object_id, msg|
          restore(find_object(object_id), msg)
        end
      elsif args.length == 2
        receiver, msg = *args
        remove_spy(receiver, msg)
      end
    end

    private

    # Looks up an object in the global ObjectSpace
    def find_object(object_id)
      ObjectSpace._id2ref(object_id)
    end

    # Global hash of known collection
    def collection
      @collection ||= Collection.new
    end

    def add_spy(receiver, msg)
      raise Errors::AlreadySpiedError if collection.contains?(receiver, msg)
      original = receiver.method(msg)
      collection.insert receiver, msg, Instance.new(msg, original)
    end

    def remove_spy(receiver, msg)
      raise NoMethodError unless receiver.respond_to? msg
      collection.remove(receiver, msg)
    end
  end
end
