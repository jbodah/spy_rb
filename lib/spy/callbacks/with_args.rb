module Spy
  module Callbacks
    class WithArgs
      def initialize(*args)
        puts 'Spy::Callbacks::WithArgs is deprecated; use Spy::Callbacks::When instead'
        @match_args = args
      end

      def before_call(*args)
        @match_args == args
      end
    end
  end
end
