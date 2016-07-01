module Spy
  class MethodCall
    attr_reader :name, :receiver, :args, :block
    attr_accessor :result

    def initialize(replayer, name, receiver, *args)
      @replayer = replayer
      @name     = name
      @receiver = receiver
      @args     = args
      @block    = proc { receiver.instance_eval &Proc.new } if block_given?
    end

    def replay
      @replayer.call
    end
  end
end
