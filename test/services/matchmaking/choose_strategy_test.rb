require "test_helper"

module Matchmaking
  class ChooseStrategyTest < ActiveSupport::TestCase
    setup do
      @subject = ChooseStrategy.new
    end

    test "returns nil if the group is not active" do
      group = group_with(name: "test", is_active: false)

      assert_nil @subject.call(group)
    end

    test "returns nil if the group is not configured" do
      group = MatchmakingGroup.new

      assert_nil @subject.call(group)
    end

    test "returns PairByFewestEncounters if the group size is 2" do
      group = group_with(name: "test", target_size: 2)

      assert_instance_of Strategies::PairByFewestEncounters, @subject.call(group)
    end

    test "returns PairByFewestEncounters that allows third participant" do
      groups = [
        group_with(name: "test", target_size: 2, size_strategy: "flexible_size"),
        group_with(name: "test", target_size: 2)
      ]

      strategies = groups.map { |group| @subject.call(group) }

      assert strategies.all?(&:allow_third_participant?)
    end

    test "returns PairByFewestEncounters that disallows third participant" do
      group = group_with(name: "test", target_size: 2, size_strategy: "exact_size")

      refute @subject.call(group).allow_third_participant?
    end

    test "returns ArrangeGroupsGenetically if the group size is greater than 2" do
      group = group_with(name: "test", target_size: 3)

      assert_instance_of Strategies::ArrangeGroupsGenetically, @subject.call(group)
    end

    test "returns ArrangeGroupsGenetically that allows flexible group sizes" do
      groups = [
        group_with(name: "test", target_size: 3, size_strategy: "flexible_size"),
        group_with(name: "test", target_size: 3)
      ]

      strategies = groups.map { |group| @subject.call(group) }

      refute strategies.all?(&:strict_group_size?)
    end

    test "returns ArrangeGroupsGenetically that enforces strict group sizing" do
      group = group_with(name: "test", target_size: 3, size_strategy: "exact_size")

      assert @subject.call(group).strict_group_size?
    end
  end
end
