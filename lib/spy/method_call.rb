module Spy
  class MethodCall
    attr_reader :name, :receiver, :args, :block
    attr_accessor :result

    def initialize(name, receiver, *args)
      @name = name
      @receiver = receiver
      @args = args

      if block_given?
        @block = -> () { receiver.instance_eval &Proc.new }
      end
    end
  end
end
