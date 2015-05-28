module Spy
  class MethodCall
    attr_reader :name, :receiver, :args, :block
    attr_accessor :result

    def initialize(replayer, name, receiver, *args)
      @replayer = replayer
      @name = name
      @receiver = receiver
      @args = args

      if block_given?
        @block = -> () { receiver.instance_eval &Proc.new }
      end
    end

    def replay
      @replayer.call
    end
  end
end
