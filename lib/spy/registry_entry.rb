module Spy
  # Isolates the format we serialize spies in when we track them
  class RegistryEntry < Struct.new(:spied, :method, :spy)
    def key
      receiver = method.is_a?(Method) ? method.receiver : nil
      "#{receiver.object_id}|#{method.name}|#{method.class}"
    end

    def ==(other)
      key == other.key
    end
  end
end
