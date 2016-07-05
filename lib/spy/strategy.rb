require 'spy/strategy/wrap'
require 'spy/strategy/intercept'

module Spy
  module Strategy
    class << self
      def factory_build(spy)
        if spy.original.is_a?(Method)
          pick_strategy(spy, spy.spied.singleton_class)
        else
          pick_strategy(spy, spy.spied)
        end
      end

      private

      def pick_strategy(spy, spied_on)
        if spy.original.owner == spied_on
          # If the object we're spying on is the owner of
          # the method under spy then we need to wrap that
          # method
          Strategy::Wrap.new(spy)
        else
          # Otherwise we can intercept it by abusing the
          # inheritance hierarchy
          Strategy::Intercept.new(spy, spied_on)
        end
      end
    end
  end
end
