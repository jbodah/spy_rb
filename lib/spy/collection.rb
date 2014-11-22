module Spy
  class Collection
    def initialize
      @store = {}
    end

    def insert(receiver, msg, value)
      @store[key_for(receiver, msg)] = value
    end

    def remove(receiver, msg)
      value = value_at(receiver, msg)
      raise Errors::MethodNotSpiedError unless value
      value.destroy
      @store.delete key_for(receiver, msg)
    end

    def contains?(receiver, msg)
      !value_at(receiver, msg).nil?
    end

    def value_at(receiver, msg)
      @store[key_for(receiver, msg)]
    end

    def key_for(receiver, msg)
      "#{receiver.object_id}|#{msg}"
    end

    def each
      @store.keys
            .map  {|k| key_parts k}
            .each {|object_id, msg| yield object_id, msg}
    end

    def key_parts(key)
      parts = key.split('|')
      parts[0] = parts[0].to_i
      parts
    end
  end
end
