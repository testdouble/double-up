module Matchmaking
  class ChooseStrategy
    def call(group)
      return nil unless group&.active?

      if group.target_size == 2
        return Strategies::PairByFewestEncounters.new(
          allow_third_participant: group.flexible_size?
        )
      end

      Strategies::ArrangeGroupsGenetically.new(
        target_group_size: group.target_size,
        strict_group_size: group.exact_size?
      )
    end
  end
end
