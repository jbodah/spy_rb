module Spy
  module Callbacks
    class When
      def initialize(filter)
        @filter = filter
      end

      def call(*args)
        @filter.call(*args)
      end
    end
  end
end
