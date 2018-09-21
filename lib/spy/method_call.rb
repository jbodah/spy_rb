module Spy
  class MethodCall
    attr_reader :spy, :name, :receiver, :caller, :args, :block
    attr_accessor :result

    def initialize(spy, replayer, name, receiver, method_caller, *args)
      @spy      = spy
      @replayer = replayer
      @name     = name
      @receiver = receiver
      @args     = args
      @caller   = method_caller
      @block    = proc { receiver.instance_eval(&Proc.new) } if block_given?
    end

    def replay
      @replayer.call
    end
  end
end
