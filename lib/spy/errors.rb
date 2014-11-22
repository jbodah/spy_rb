module Spy
  module Errors
    MethodNotSpiedError = Class.new(StandardError)
    AlreadySpiedError   = Class.new(StandardError)
  end
end
