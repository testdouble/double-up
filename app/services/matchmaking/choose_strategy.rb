module Matchmaking
  class ChooseStrategy
    def call(group)
      return nil unless group&.active?

      return Strategies::PairByFewestEncounters.new if group.target_size == 2

      Strategies::ArrangeGroupsGenetically.new(target_group_size: group.target_size)
    end
  end
end
