module Spy
  class Instance
    module Filters
      class Wrap
        def initialize(block)
          @block = block
        end
      end
    end
  end
end
