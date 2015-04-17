module Spy
  class Instance
    module Filters
      class WithArgs
        def initialize(*args)
          puts 'Spy::Instance::Filters::WithArgs is deprecated; use Spy::Instance::Filters::When instead'
          @match_args = args
        end

        def before_call(*args)
          @match_args == args
        end
      end
    end
  end
end
