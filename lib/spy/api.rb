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
        return core.add_spy *(args << :method)
      end
      raise ArgumentError
    end

    # TODO docs
    def on_any_instance(mod, msg)
      core.add_spy(mod, msg, :instance_method)
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
        return core.remove_spy *(args << :method)
      when 3
        return core.remove_spy *args
      end
      raise ArgumentError
    end

    private

    def core
      @core ||= Core.new
    end
  end
end
