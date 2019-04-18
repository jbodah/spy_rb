require 'spy/replace_method'

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
        ReplaceMethod.call(@target, @spy, mode: :stub)
      end

      def undo
        ReplaceMethod.call(@target, @spy, remove_existing: true)
      end
    end
  end
end
