require 'spy/replace_method'

module Spy
  module Strategy
    class Wrap
      def initialize(spy)
        @spy = spy
      end

      def apply
        ReplaceMethod.call(@spy.original.owner, @spy, mode: :stub)
      end

      def undo
        ReplaceMethod.call(@spy.original.owner, @spy, mode: :restore)
      end
    end
  end
end
