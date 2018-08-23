require 'spy'
require 'set'

module Spy
  module Util
    class TypeAnalysis
      attr_reader :type_info

      def initialize(spy)
        @spy = spy
        @type_info = {}
      end

      def decorate
        if @spy.is_a?(Spy::Multi)
          spies = @spy.spies
        else
          spies = [@spy]
        end

        spies.each do |spy|
          spy.wrap do |method_call, &block|
            record_args(method_call)
            block.call
            record_rv(method_call)
          end
        end

        self
      end

      def respond_to_missing?(sym, incl_private = false)
        @spy.respond_to_missing?(sym, incl_private)
      end

      def method_missing(sym, *args, &block)
        @spy.send(sym, *args, &block)
      end

      private

      def record_args(method_call)
        @type_info[method_call.name] ||= {}
        @type_info[method_call.name][:args] ||= []
        method_call.args.each.with_index do |arg, idx|
          @type_info[method_call.name][:args][idx] ||= Set.new
          @type_info[method_call.name][:args][idx] << type_of(arg)
        end
      end

      def record_rv(method_call)
        @type_info[method_call.name] ||= {}
        @type_info[method_call.name][:return_value] ||= Set.new
        @type_info[method_call.name][:return_value] << type_of(method_call.result)
      end

      def type_of(obj)
        if obj.is_a?(Array) && obj.size > 0
          [Array, obj[0].class]
        else
          obj.class
        end
      end
    end
  end
end
