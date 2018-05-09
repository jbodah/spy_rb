module Spy
  module Strategy
    class Wrap
      def initialize(spy)
        @spy = spy
      end

      def apply
        spy = @spy
        @spy.original.owner.class_eval do
          # Replace the method with the spy
          define_method spy.original.name do |*args, &block|
            spy.call(self, *args, &block)
          end

          # Make the visibility of the spy match the spied original
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
