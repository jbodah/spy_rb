module Spy
  class Multi
    def initialize(spies)
      @spies = spies
    end

    def call_count
      @spies.map(&:call_count).reduce(&:+)
    end

    def [](name)
      @spies.find { |spy| spy.name == name }
    end
  end
end
