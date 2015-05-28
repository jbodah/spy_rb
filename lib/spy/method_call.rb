module Spy
  class MethodCall
    attr_reader :receiver, :args, :block
    attr_accessor :result

    def initialize(receiver, *args)
      @receiver = receiver
      @args = args

      if block_given?
        @block = -> () { receiver.instance_eval &Proc.new }
      end
    end
  end
end
