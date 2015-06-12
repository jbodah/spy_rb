module Spy
  module Errors
    MethodNotSpiedError         = Class.new(StandardError)
    AlreadySpiedError           = Class.new(StandardError)
    UnableToEmptySpyCollection  = Class.new(StandardError)
  end
end
