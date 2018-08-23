module Spy
  class Multi
    attr_reader :spies

    def initialize(spies)
      @spies = spies
    end

    def call_count
      @spies.map(&:call_count).reduce(&:+)
    end

    def [](name)
      @spies.find { |spy| spy.name == name }
    end

    def uncalled
      @spies.select { |spy| spy.call_count == 0 }
    end
  end
end
