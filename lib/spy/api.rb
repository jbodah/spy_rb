require 'spy/core'

module Spy
  # The core module that users will interface. `Spy::API` is implemented
  # in a module via `::extend`:
  #
  #   MySpy.exted Spy::API
  #   spy = MySpy.on(Object, :name)
  #
  # By default `Spy` implements `Spy::API`
  #
  # `Spy::API` is primarily responsible for maps user arguments into
  # a format that `Spy::Core` can understand
  #
  # See `Spy::Instance` for the API for interacting with individual spies
  module API
    # Spies on calls to a method made on a target object
    #
    # @param [Object] target - the object you want to spy on
    # @param [Symbol] msg - the name of the method to spy on
    # @returns [Spy::Instance]
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
    # @example stop spying on every spied message
    #
    #   Spy.restore(:all)
    #
    # @example stop spying on the given receiver and message
    #
    #   Spy.restore(receiver, msg)
    #
    # @example stop spying on the given object, message, and method type (e.g. :instance_method)
    #
    #   Spy.restore(object, msg, method_type)
    #
    # @param args - supports multiple signatures
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
