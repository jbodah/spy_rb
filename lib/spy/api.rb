require 'spy/core'

module Spy
  module API
    # Initializes a new spy instance for the method
    #
    # With two args:
    # @param receiver - the receiver of the message you want to spy on
    # @param msg - the message passed to the receiver that you want to spy on
    def on(*args)
      case args.length
      when 2
        spied, msg = *args
        return core.add_spy(spied, spied.method(msg))
      end
      raise ArgumentError
    end

    # TODO docs
    def on_any_instance(spied, msg)
      core.add_spy(spied, spied.instance_method(msg))
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
        return core.remove_all_spies if args.first == :all
      when 2
        spied, msg = *args
        return core.remove_spy(spied, spied.method(msg))
      when 3
        spied, msg, method_type = *args
        return core.remove_spy(spied, spied.send(method_type, msg))
      end
      raise ArgumentError
    end

    private

    def core
      @core ||= Core.new
    end
  end
end
