module Spy
  class MethodCall
    attr_reader :context, :args
    attr_accessor :result

    def initialize(context, *args)
      @context = context
      @args = args
    end
  end
end
