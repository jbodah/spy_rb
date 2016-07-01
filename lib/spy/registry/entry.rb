module Spy
  class Registry
    # Abstraction to isolate domain logic
    class Entry < Struct.new(:spied, :method, :spy)
      def key
        receiver = method.is_a?(Method) ? method.receiver : nil
        "#{receiver.object_id}|#{method.name}|#{method.class}"
      end

      def ==(other)
        key == other.key
      end
    end
  end
end
