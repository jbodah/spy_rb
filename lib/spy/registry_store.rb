module Spy
  # Works with RegistryEntry abstractions to allow the
  # store data structure to be easily swapped
  class RegistryStore
    include Enumerable

    def initialize
      @internal = {}
    end

    def insert(entry)
      @internal[entry.key] = entry
    end

    def remove(entry)
      @internal.delete(entry.key)
    end

    def each
      e = Enumerator.new do |y|
        @internal.values.each {|v| y << v}
      end
      block_given? ? e.each(&Proc.new) : e
    end

    def empty?
      none?
    end
  end
end
