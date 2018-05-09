module Spy
  module Strategy
    class Intercept
      def initialize(spy)
        @spy = spy
        @target =
          if spy.original.is_a?(Method)
            spy.spied.singleton_class
          else
            spy.spied
          end
      end

      def apply
        spy = @spy
        @target.class_eval do
          # Add the spy to the intercept target
          define_method spy.original.name do |*args, &block|
            spy.call(self, *args, &block)
          end

          # Make the visibility of the spy match the spied original
          send(spy.visibility, spy.original.name)
        end
      end

      def undo
        spy = @spy
        @target.class_eval do
          remove_method spy.original.name
        end
      end
    end
  end
end
