module Spy
  class Instance
    module Filters
      class Wrap
        def initialize(wrapper)
          @wrapper = wrapper
        end

        def around_call(context, *args, &original)
          @wrapper.call(context, *args) &original
        end
      end
    end
  end
end
