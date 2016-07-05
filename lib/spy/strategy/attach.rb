module Spy
  module Strategy
    module Attach
      def self.call(spy, target)
        target.class_eval do
          # Replace the method with the spy
          define_method spy.original.name do |*args, &block|
            spy.call(self, *args, &block)
          end

          # Make the visibility of the spy match the spied original
          send(spy.visibility, spy.original.name)
        end
      end
    end
  end
end
