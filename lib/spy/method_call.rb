module Spy
  class MethodCall
    attr_reader :receiver, :args
    attr_accessor :result

    def initialize(receiver, *args)
      @receiver = receiver
      @args = args
    end
  end
end
