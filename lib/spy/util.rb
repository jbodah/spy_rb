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
        prepare_spy(@spy)
        self
      end

      def respond_to_missing?(sym, incl_private = false)
        @spy.respond_to_missing?(sym, incl_private)
      end

      def method_missing(sym, *args, &block)
        @spy.send(sym, *args, &block)
      end

      private

      def prepare_spy(spy)
        if spy.is_a?(Spy::Multi)
          spy.spies.each(&method(:prepare_spy))
        else
          spy.wrap do |method_call, &block|
            record_args(method_call)
            block.call
            record_rv(method_call)
          end
        end
      end

      def record_args(method_call)
        owner = method_call.spy.original.owner
        name = method_call.name
        @type_info[owner] ||= {}
        @type_info[owner][name] ||= {}
        @type_info[owner][name][:args] ||= []
        method_call.args.each.with_index do |arg, idx|
          @type_info[owner][name][:args][idx] ||= Set.new
          @type_info[owner][name][:args][idx] << type_of(arg)
        end
      end

      def record_rv(method_call)
        owner = method_call.spy.original.owner
        name = method_call.name
        @type_info[owner] ||= {}
        @type_info[owner][name] ||= {}
        @type_info[owner][name][:return_value] ||= Set.new
        @type_info[owner][name][:return_value] << type_of(method_call.result)
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
