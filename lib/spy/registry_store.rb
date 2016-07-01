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
      return to_enum unless block_given?
      @internal.values.each { |v| yield v }
    end

    def empty?
      none?
    end
  end
end
