require 'spy/determine_visibility'
require 'spy/strategy/base'

module Spy
  module Strategy
    class Intercept
      def initialize(spy)
        @spy = spy
        @target =
          case spy.original
          when Method
            spy.spied.singleton_class
          when UnboundMethod
            spy.spied
          when FakeMethod
            spy.spied.singleton_class
          end
      end

      def apply
        spy = @spy
        @target.class_eval do
          # Add the spy to the intercept target
          define_method spy.original.name do |*args, &block|
            Spy::Strategy::Base.call(spy, self, *args, &block)
          end

          # Make the visibility of the spy match the spied original
          unless spy.original.is_a?(FakeMethod)
            visibility = DetermineVisibility.call(spy.original)
            send(visibility, spy.original.name)
          end
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
