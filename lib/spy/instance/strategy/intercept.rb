module Spy
  class Instance
    module Strategy
      class Intercept
        def initialize(spy, intercept_target)
          @spy = spy
          @intercept_target = intercept_target
        end

        def apply
          spy = @spy
          @intercept_target.class_eval do
            define_method spy.original.name do |*args|
              spy.before_call(*args)
              if spy.original.is_a?(UnboundMethod)
                spy.original.bind(self).call(*args)
              else
                spy.original.call(*args)
              end
            end
            send(spy.visibility, spy.original.name)
          end
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
