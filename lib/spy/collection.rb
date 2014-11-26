module Spy
  class Collection
    include Enumerable

    def initialize
      @store = {}
    end

    def insert(receiver, msg, method_type, value)
      @store[key_for(receiver, msg, method_type)] = value
    end

    def remove(receiver, msg, method_type)
      value = @store[key_for(receiver, msg, method_type)]
      raise Errors::MethodNotSpiedError unless value
      @store.delete(key_for(receiver, msg, method_type))
    end

    # Removes each element from the collection and calls the block
    # with each deleted element
    def remove_all
      map do |object_id, msg, method_type|
        yield remove(find_object(object_id), msg, method_type)
      end
    end

    def contains?(receiver, msg, method_type)
      !@store[key_for(receiver, msg, method_type)].nil?
    end

    private

    def each
      @store.keys
            .map  {|k| key_parts k}
            .each {|object_id, msg, method_type| yield object_id, msg, method_type}
    end

    def key_for(receiver, msg, method_type)
      "#{receiver.object_id}|#{msg}|#{method_type}"
    end

    # Looks up an object in the global ObjectSpace
    def find_object(object_id)
      ObjectSpace._id2ref(object_id)
    end

    def key_parts(key)
      parts = key.split('|')
      parts[0] = parts[0].to_i
      parts[1] = parts[1].to_sym
      parts[2] = parts[2].to_sym
      parts
    end
  end
end
