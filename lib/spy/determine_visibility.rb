module Spy
  module DetermineVisibility
    # @param [Method, UnboundMethod] method
    # @returns [Symbol] whether the method is public, private, or protected
    def self.call(method)
      owner = method.owner
      %w(public private protected).each do |vis|
        query = "#{vis}_method_defined?"
        if owner.respond_to?(query) && owner.send(query, method.name)
          return vis
        end
      end
      raise NoMethodError, "couldn't find method #{method.name} belonging to #{owner}"
    end
  end
end
