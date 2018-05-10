module Spy
  module Errors
    Error = Class.new(StandardError)
    MethodNotSpiedError = Class.new(Spy::Errors::Error)
    AlreadySpiedError = Class.new(Spy::Errors::Error)
  end
end
