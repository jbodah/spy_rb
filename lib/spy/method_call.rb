module Spy
  class MethodCall
    attr_reader :receiver, :backtrace, :args, :block, :result

    def initialize(spy, receiver, args, block, backtrace)
      @spy = spy
      @receiver = receiver
      @args = args
      @block = block
      @backtrace = backtrace
    end

    def name
      @spy.original.name
    end

    def call_original(persist_result = false)
      result = @spy.call_original(@receiver, @args, @block)
      @result = result if persist_result
      result
    end

    alias replay call_original
    alias caller backtrace
  end
end
