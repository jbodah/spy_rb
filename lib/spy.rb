require_relative 'spy/instance'

module Spy
  module Errors
    AlreadySpiedError = Class.new(StandardError)
  end
 
  module ClassMethods
    include Errors

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
        spies.each {|k,v| restore(find_object(k), v.msg)}
      elsif args.length == 2
        object, msg = *args
        spies[object.object_id].destroy
        spies.delete(object.object_id)
      end
    end

    private

    # Looks up an object in the global ObjectSpace
    def find_object(object_id)
      ObjectSpace._id2ref(object_id)
    end

    # Global hash of known spies
    def spies
      @spies ||= {}
    end

    def add_spy(receiver, msg)
      raise AlreadySpiedError if spies[receiver.object_id]
      original = receiver.method(msg)
      spies[receiver.object_id] = Instance.new(msg, original)
    end
  end

  include Errors
  extend ClassMethods
end
