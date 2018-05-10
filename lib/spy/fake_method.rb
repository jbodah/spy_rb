module Spy
  class FakeMethod
    attr_reader :name

    def initialize(name, &block)
      @name = name
      @block = block
    end

    def call(*args, &block)
      @block.call(*args, &block)
    end
  end
end
