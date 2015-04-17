module Spy
  class Instance
    module Strategy
      class Intercept
        def initialize(spy, intercept_target)
          @spy = spy
          @intercept_target = intercept_target
        end

        def apply
          @spy.attach_to(@intercept_target)
        end

        def undo
          spy = @spy
          @intercept_target.class_eval do
            remove_method spy.original.name
          end
        end
      end
    end
  end
end
