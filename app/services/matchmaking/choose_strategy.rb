module Matchmaking
  class ChooseStrategy
    def initialize(config: nil)
      @config = config || Rails.application.config.x.matchmaking
    end

    def call(grouping)
      group_config = @config.send(grouping.intern)
      return nil unless group_config&.active

      return Strategies::PairByFewestEncounters.new if group_config.size == 2

      Strategies::ArrangeGroupsGenetically.new(target_group_size: group_config.size)
    end
  end
end
