module Spy
  class CollectionEntry < Struct.new(:receiver, :msg, :method_type)
    attr_accessor :value

    def key
      "#{receiver.object_id}|#{msg}|#{method_type}"
    end

    def ==(other)
      key == other.key
    end

    module ClassMethods
      def parse(key)
        new *parse_key(key)
      end

      def parse_key(key)
        parts = key.split('|')
        parts[0] = find_object(parts[0].to_i)
        parts[1] = parts[1].to_sym
        parts[2] = parts[2].to_sym
        parts
      end

      # Looks up an object in the global ObjectSpace
      def find_object(object_id)
        ObjectSpace._id2ref(object_id)
      end
    end

    extend ClassMethods
  end
end
