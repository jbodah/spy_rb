require 'spy/method_call'

module Spy
  module Strategy
    module Base
      class << self
        def call(spy, receiver, *args, &block)
          spy.instance_eval do
            # TODO - abstract the method call into an object and cache this in
            #   method using an instance variable instead of a local variable.
            #   This will let us be a bit more elegant about how we do before/after
            #   callbacks. We can also merge MethodCall with this responsibility so
            #   it isn't just a data struct
            is_active = if @internal[:conditional_filters].any?
                          mc = Spy::Strategy::Base._build_method_call(spy, receiver, *args, &block)
                          @internal[:conditional_filters].all? { |f| f.call(mc) }
                        else
                          true
                        end

            return Spy::Strategy::Base._call_original(spy, receiver, *args, &block) unless is_active

            if @internal[:before_callbacks].any?
              mc = Spy::Strategy::Base._build_method_call(spy, receiver, *args, &block)
              @internal[:before_callbacks].each { |f| f.call(mc) }
            end

            if @internal[:around_procs].any?
              mc = Spy::Strategy::Base._build_method_call(spy, receiver, *args, &block)

              # Procify the original call
              # Still return the result from it
              result = nil
              original_proc = proc do
                result = Spy::Strategy::Base._call_and_record(spy, receiver, args, { :record => mc }, &block)
              end

              # Keep wrapping the original proc with each around_proc
              @internal[:around_procs].reduce(original_proc) do |p, wrapper|
                proc { wrapper.call(mc, &p) }
              end.call
            else
              result = Spy::Strategy::Base._call_and_record(spy, receiver, args, &block)
            end

            if @internal[:after_callbacks].any?
              mc = @call_history.last
              @internal[:after_callbacks].each { |f| f.call(mc) }
            end

            result
          end
        end

        def _build_method_call(spy, receiver, *args, &block)
          Spy::MethodCall.new(
            proc { Spy::Strategy::Base._call_original(spy, receiver, *args, &block) },
            spy.original.name,
            receiver,
            caller.drop_while { |path| path =~ /lib\/spy\/strategy/ },
            *args,
            &block)
        end

        def _call_and_record(spy, receiver, args, opts = {}, &block)
          spy.instance_eval do
            if @internal[:instead]
              @internal[:instead].call(Spy::Strategy::Base._build_method_call(spy, receiver, *args, &block))
            else
              record = opts[:record] || Spy::Strategy::Base._build_method_call(spy, receiver, *args, &block)
              @call_history << record

              result = Spy::Strategy::Base._call_original(spy, receiver, *args, &block)
              record.result = result
            end
          end
        end

        def _call_original(spy, receiver, *args, &block)
          if spy.original.is_a?(UnboundMethod)
            spy.original.bind(receiver).call(*args, &block)
          else
            spy.original.call(*args, &block)
          end
        end
      end
    end
  end
end
