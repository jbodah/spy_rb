require_relative 'spy/instance'

module Spy
  module Errors
    AlreadySpiedError = Class.new(StandardError)
  end
 
  module ClassMethods
    include Errors

    def on(receiver, msg)
      add_spy(receiver, msg)
    end

    def restore(*args)
      if args.length == 1
        spies.each {|k,v| restore(find_object(k), v.msg)} if args[0] == :all
      elsif args.length == 2
        object, msg = *args
        spies[object.object_id].destroy
        spies.delete(object.object_id)
      end
    end

    private

    def find_object(object_id)
      ObjectSpace._id2ref(object_id)
    end

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
