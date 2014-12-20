require 'spy/instance/strategy/wrap'
require 'spy/instance/strategy/intercept'

module Spy
  class Instance
    module Strategy
      class << self
        def factory_build(spy)
          if spy.original.is_a?(Method)
            if spy.original.owner == spy.spied.singleton_class
              Strategy::Wrap.new(spy)
            else
              Strategy::Intercept.new(spy, spy.spied.singleton_class)
            end
          else
            if spy.original.owner == spy.spied
              Strategy::Wrap.new(spy)
            else
              Strategy::Intercept.new(spy, spy.spied)
            end
          end
        end
      end
    end
  end
end
