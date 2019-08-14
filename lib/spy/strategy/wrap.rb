require 'spy/replace_method'

module Spy
  module Strategy
    class Wrap
      def initialize(spy)
        @spy = spy
      end

      def apply
        ReplaceMethod.call(@spy.original.owner, @spy, mode: :stub, remove_existing: true)
      end

      def undo
        ReplaceMethod.call(@spy.original.owner, @spy, mode: :restore, remove_existing: true)
      end
    end
  end
end
