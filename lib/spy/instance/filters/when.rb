module Spy
  class Instance
    module Filters
      class When
        def initialize(block)
          @block = block
        end

        def before_call(*args)
          @block.call(*args)
        end
      end
    end
  end
end
