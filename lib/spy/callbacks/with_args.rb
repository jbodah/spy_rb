module Spy
  module Callbacks
    class WithArgs
      def initialize(*args)
        @match_args = args
      end

      def call(result, *args)
        @match_args == args
      end
    end
  end
end
