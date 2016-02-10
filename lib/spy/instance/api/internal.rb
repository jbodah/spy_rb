require 'spy/method_call'

module Spy
  class Instance
    module API
      # The API we expose internally to our collaborators
      module Internal
        # TODO: Not sure if this is the best place for this
        #
        # Defines the spy on the target object
        def attach_to(target)
          spy = self
          target.class_eval do
            define_method spy.original.name do |*args, &block|
              spy.call(self, *args, &block)
            end
            send(spy.visibility, spy.original.name)
          end
        end

        # Call the spied method using the given receiver and arguments.
        #
        # receiver is required to allow calling of UnboundMethods such as
        # instance methods defined on a Class
        def call(receiver, *args, &block)
          # TODO - abstract the method call into an object and cache this in
          #   method using an instance variable instead of a local variable.
          #   This will let us be a bit more elegant about how we do before/after
          #   callbacks. We can also merge MethodCall with this responsibility so
          #   it isn't just a data struct
          is_active = if @conditional_filters.any?
                        mc = build_method_call(receiver, *args, &block)
                        @conditional_filters.all? {|f| f.call(mc)}
                      else
                        true
                      end

          return call_original(receiver, *args, &block) if !is_active

          if @before_callbacks.any?
            mc = build_method_call(receiver, *args, &block)
            @before_callbacks.each {|f| f.call(mc)}
          end

          if @around_procs.any?
            mc = build_method_call(receiver, *args, &block)

            # Procify the original call
            # Still return the result from it
            result = nil
            original_proc = Proc.new do
              result = call_and_record(receiver, args, { :record => mc }, &block)
            end

            # Keep wrapping the original proc with each around_proc
            @around_procs.reduce(original_proc) do |p, wrapper|
              Proc.new { wrapper.call(mc, &p) }
            end.call
          else
            result = call_and_record(receiver, args, &block)
          end

          if @after_callbacks.any?
            mc = @call_history.last
            @after_callbacks.each {|f| f.call(mc)}
          end

          result
        end

        private

        def build_method_call(receiver, *args, &block)
          Spy::MethodCall.new(
            proc { call_original(receiver, *args, &block) },
            original.name,
            receiver,
            *args,
            &block)
        end

        def call_and_record(receiver, args, opts = {}, &block)
          record = opts[:record] || build_method_call(receiver, *args, &block)
          @call_history << record

          result = call_original(receiver, *args, &block)
          record.result = result
        end

        def call_original(receiver, *args, &block)
          if original.is_a?(UnboundMethod)
            original.bind(receiver).call(*args, &block)
          else
            original.call(*args, &block)
          end
        end
      end
    end
  end
end
