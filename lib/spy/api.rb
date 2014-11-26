require_relative 'instance'
require_relative 'collection'
require_relative 'errors'

module Spy
  module API
    # Initializes a new spy instance for the method
    #
    # With two args:
    # @param receiver - the receiver of the message you want to spy on
    # @param msg - the message passed to the receiver that you want to spy on
    def on(*args)
      if args.length == 2
        receiver, msg = *args
        add_spy(receiver, msg, :method)
      else
        raise ArgumentError
      end
    end

    # TODO docs
    def on_any_instance(mod, msg)
      add_spy(mod, msg, :instance_method)
    end

    # Stops spying on the method and restores its original functionality
    #
    # @param args - supports multiple signatures
    #
    #               Spy.restore(:all)           => stops spying on every spied message
    #               Spy.restore(receiver, msg)  => stops spying on the given receiver and message
    def restore(*args)
      if args.length == 1 && args[0] == :all
        collection.each do |object_id, msg, method_type|
          restore(find_object(object_id), msg, method_type)
        end
      elsif args.length == 2
        receiver, msg = *args
        # TODO is this what we want to default to?
        remove_spy(receiver, msg, :method)
      elsif args.length == 3
        receiver, msg, method_type = *args
        remove_spy(receiver, msg, method_type)
      else
        raise ArgumentError
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

    def add_spy(receiver, msg, method_type)
      raise Errors::AlreadySpiedError if collection.contains?(receiver, msg, method_type)
      collection.insert receiver, msg, method_type, Instance.new(receiver, msg, method_type)
    end

    def remove_spy(receiver, msg, method_type)
      raise NoMethodError unless receiver.send("#{method_type}s".to_sym).include? msg
      collection.remove(receiver, msg, method_type)
    end
  end
end
