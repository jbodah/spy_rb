require 'spy/strategy/attach'

module Spy
  module Strategy
    class Intercept
      def initialize(spy, intercept_target)
        @spy = spy
        @intercept_target = intercept_target
      end

      def apply
        Spy::Strategy::Attach.call(@spy, @intercept_target)
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
