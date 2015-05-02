require 'spy/core'

module Spy
  module API
    # Spies on calls to a method made on an object
    #
    # @param target - the object you want to spy on
    # @param msg - the name of the method to spy on
    def on(target, msg)
      core.add_spy(target, target.method(msg))
    end

    # Spies on calls to a method made on any instance of some class or module
    #
    # @param target - class or module to spy on
    # @param msg - name of the method to spy on
    # @returns [Spy::Instance]
    def on_any_instance(target, msg)
      raise ArgumentError unless target.respond_to?(:instance_method)
      core.add_spy(target, target.instance_method(msg))
    end

    # Stops spying on the method and restores its original functionality
    #
    # @param args - supports multiple signatures
    #
    #   Spy.restore(:all)
    #       => stops spying on every spied message
    #
    #   Spy.restore(receiver, msg)
    #       => stops spying on the given receiver and message (assumes :method)
    #
    #   Spy.restore(reciever, msg, method_type)
    #       =>  stops spying on the given receiver and message of method_type
    def restore(*args)
      case args.length
      when 1
        core.remove_all_spies if args.first == :all
      when 2
        target, msg = *args
        core.remove_spy(target, target.method(msg))
      when 3
        target, msg, method_type = *args
        core.remove_spy(target, target.send(method_type, msg))
      else
        raise ArgumentError
      end
    end

    private

    def core
      @core ||= Core.new
    end
  end
end
