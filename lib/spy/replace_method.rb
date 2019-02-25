require 'spy/method_call'

module Spy
  module ReplaceMethod
    def self.call(klass, spy, mode: nil, remove_existing: false)
      klass.class_eval do
        name = spy.original.name

        remove_method(name) if remove_existing

        case mode
        when :stub
          define_method(name, ReplaceMethod.impl(spy))
        when :restore
          define_method(name, spy.original)
        end
      end
    end

    def self.impl(spy)
      proc do |*args, &block|
        backtrace = caller.drop_while { |path| path =~ /lib\/spy\/replace_method\.rb$/ }
        method_call = MethodCall.new(spy, self, args, block, backtrace)
        spy.apply(method_call)
      end
    end
  end
end
