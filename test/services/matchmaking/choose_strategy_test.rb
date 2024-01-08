require "test_helper"

module Matchmaking
  class ChooseStrategyTest < ActiveSupport::TestCase
    setup do
      @subject = ChooseStrategy
    end

    test "returns nil if the group is not active" do
      config = matchmaking_config(test: {active: false})

      assert_nil @subject.new(config: config).call("test")
    end

    test "returns nil if the group is not configured" do
      config = matchmaking_config

      assert_nil @subject.new(config: config).call("unknown")
    end

    test "returns PairByFewestEncounters if the group size is 2" do
      config = matchmaking_config(test: {size: 2})

      assert_instance_of Strategies::PairByFewestEncounters, @subject.new(config: config).call("test")
    end

    test "returns ArrangeGroupsGenetically if the group size is greater than 2" do
      config = matchmaking_config(test: {size: 3})

      assert_instance_of Strategies::ArrangeGroupsGenetically, @subject.new(config: config).call("test")
    end
  end
end
