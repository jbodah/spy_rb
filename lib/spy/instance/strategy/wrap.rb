module Spy
  class Instance
    module Strategy
      class Wrap
        def initialize(spy)
          @spy = spy
        end

        def apply
          @spy.attach_to(@spy.original.owner)
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
