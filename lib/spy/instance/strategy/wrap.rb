module Spy
  class Instance
    module Strategy
      class Wrap
        def initialize(spy)
          @spy = spy
        end

        def apply
          spy = @spy
          spy.original.owner.class_eval do
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
          spy.original.owner.class_eval do
            remove_method spy.original.name
            define_method spy.original.name, spy.original
            send(spy.visibility, spy.original.name)
          end
        end
      end
    end
  end
end
