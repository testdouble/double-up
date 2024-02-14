require "test_helper"

module Matchmaking
  class ChooseStrategyTest < ActiveSupport::TestCase
    setup do
      @subject = ChooseStrategy.new
    end

    test "returns nil if the group is not active" do
      group = group_with(name: "test", active: false)

      assert_nil @subject.call(group)
    end

    test "returns nil if the group is not configured" do
      group = MatchmakingGroup.new

      assert_nil @subject.call(group)
    end

    test "returns PairByFewestEncounters if the group size is 2" do
      group = group_with(name: "test", size: 2)

      assert_instance_of Strategies::PairByFewestEncounters, @subject.call(group)
    end

    test "returns ArrangeGroupsGenetically if the group size is greater than 2" do
      group = group_with(name: "test", size: 3)

      assert_instance_of Strategies::ArrangeGroupsGenetically, @subject.call(group)
    end
  end
end
