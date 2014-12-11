module Spy
  module Callbacks
    class When
      def initialize(filter)
        @filter = filter
      end

      def call(result, *args)
        @filter.call(*args)
      end
    end
  end
end
