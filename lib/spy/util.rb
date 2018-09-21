require 'spy'
require 'set'

module Spy
  module Util
    # TODO: @jbodah 2018-09-21: superclass merge
    class YARDFormatter
      def format(info)
        acc = []
        info[:args].each do |arg_values|
          names = types_to_names(arg_values)
          type_names = condense_names(names)
          acc << "# @param [#{type_names.join(", ")}]"
        end
        names = types_to_names(info[:return_value])
        type_names = condense_names(names)
        acc << "# @return [#{type_names.join(", ")}]"
        acc.join("\n")
      end

      def types_to_names(types)
        types.map do |arg_value|
          if arg_value.is_a?(Array)
            head = arg_value[0]
            tail = types_to_names(arg_value[1])
            "#{head.name}<#{tail.join(", ")}>"
          else
            arg_value.name
          end
        end
      end

      def condense_names(names)
        if names.include?("TrueClass") && names.include?("FalseClass")
          names.delete("TrueClass")
          names.delete("FalseClass")
          names << "Boolean"
        end
        # todo also prune depth
        %w(Set Array Hash).each do |container|
          if names.include?(container) && names.any? { |n| /#{container}</ =~ n }
            names.delete(container)
          end
        end
        names
      end
    end

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

      def respond_to?(sym, incl_private = false)
        @spy.respond_to?(sym, incl_private)
      end

      def method_missing(sym, *args, &block)
        if @spy.respond_to?(sym)
          @spy.send(sym, *args, &block)
        else
          super
        end
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

      def type_of(obj, depth: 0)
        # NOTE: @jbodah 2018-09-21: disabling depth for now
        return obj.class if depth > 0

        if obj.is_a?(Array) && obj.size > 0
          [Array, [type_of(obj.first, depth: 1)]]
        elsif obj.is_a?(Hash) && obj.size > 0
          [Hash, [type_of(obj.first[0]), type_of(obj.first[1])]]
        elsif defined?(Set) && obj.is_a?(Set) && obj.size > 0
          [Set, [type_of(obj.first)]]
        else
          obj.class
        end
      end
    end
  end
end
