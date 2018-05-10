require 'spy/determine_visibility'
require 'spy/strategy/base'

module Spy
  module Strategy
    class Wrap
      def initialize(spy)
        @spy = spy
        @visibility = DetermineVisibility.call(spy.original)
      end

      def apply
        spy = @spy
        visibility = @visibility
        @spy.original.owner.class_eval do
          undef_method spy.original.name

          # Replace the method with the spy
          define_method spy.original.name do |*args, &block|
            Spy::Strategy::Base.call(spy, self, *args, &block)
          end

          # Make the visibility of the spy match the spied original
          send(visibility, spy.original.name)
        end
      end

      def undo
        spy = @spy
        visibility = @visibility
        spy.original.owner.class_eval do
          remove_method spy.original.name
          define_method spy.original.name, spy.original
          send(visibility, spy.original.name)
        end
      end
    end
  end
end
