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
          is_active = @conditional_filters.all? {|f| f.call(*args)}

          if is_active
            @before_callbacks.each {|f| f.call(*args)}
          end

          if @around_procs.any?
            # Procify the original call
            original_proc = Proc.new do
              record = track_call(receiver, *args, &block) if is_active
              result = call_original(receiver, *args, &block)
              record.result = result if is_active
            end

            # Keep wrapping the original proc with each around_proc
            @around_procs.reduce(original_proc) do |p, wrapper|
              Proc.new { wrapper.call receiver, *args, &p }
            end.call
          else
            record = track_call(receiver, *args, &block) if is_active
            result = call_original(receiver, *args, &block)
            record.result = result if is_active
          end

          if is_active
            @after_callbacks.each {|f| f.call(*args)}
          end

          result
        end

        private

        def track_call(receiver, *args, &block)
          replayer = proc { call_original(receiver, *args, &block) }
          record = Spy::MethodCall.new(replayer, original.name, receiver, *args, &block)
          @call_history << record
          record
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
