module Spy
  class Collection
    def initialize
      @store = {}
    end

    def insert(receiver, msg, method_type, value)
      @store[key_for(receiver, msg, method_type)] = value
    end

    def remove(receiver, msg, method_type)
      value = value_at(receiver, msg, method_type)
      raise Errors::MethodNotSpiedError unless value
      value.destroy
      @store.delete key_for(receiver, msg, method_type)
    end

    def contains?(receiver, msg, method_type)
      !value_at(receiver, msg, method_type).nil?
    end

    def value_at(receiver, msg, method_type)
      @store[key_for(receiver, msg, method_type)]
    end

    def key_for(receiver, msg, method_type)
      "#{receiver.object_id}|#{msg}|#{method_type}"
    end

    def each
      @store.keys
            .map  {|k| key_parts k}
            .each {|object_id, msg, method_type| yield object_id, msg, method_type}
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
