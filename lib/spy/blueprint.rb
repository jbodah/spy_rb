module Spy
  class Blueprint
    attr_reader :target, :msg, :type

    def initialize(target, msg, type)
      @target = target
      @msg = msg
      @type = type
      @caller = _caller
    end

    alias :_caller :caller

    def caller
      @caller
    end

    def to_s
      [@target.object_id, @msg, @type].join("|")
    end
  end
end
