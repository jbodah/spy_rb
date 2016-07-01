module Spy
  module Errors
    MethodNotSpiedError           = Class.new(StandardError)
    AlreadySpiedError             = Class.new(StandardError)
    UnableToEmptySpyRegistryError = Class.new(StandardError)
  end
end
