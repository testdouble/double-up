module Matchmaking
  class BalanceGroups
    def call(participants, target_group_size)
      return [] if participants.size < 2

      group_count = (participants.size.to_f / target_group_size).ceil

      # Distribute the participants into groups of the target size in a round-robin fashion to ensure a decent
      # initial distribution of participants where no participant is left out
      initial_groups = participants.each_with_index.with_object(Array.new(group_count) { [] }) do |(participant, index), groups|
        groups[index % group_count] << participant
      end

      # Reallocate the participants in the last group to the other smaller groups
      if initial_groups.any? { |group| group.size < 2 } && initial_groups.size > 1
        last_group = initial_groups.pop
        last_group.each { |item| initial_groups.min_by(&:size) << item }
      end

      # Ensure that no group is larger than the target size + 1
      initial_groups.flat_map do |group|
        if group.size > target_group_size + 1
          group.each_slice(target_group_size).to_a
        else
          [group]
        end
      end
    end
  end
end
