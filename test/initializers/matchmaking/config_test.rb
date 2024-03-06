require "test_helper"

module Matchmaking
  class ConfigTest < ActiveSupport::TestCase
    test "validates valid" do
      config = {
        test1: {active_in: "all", schedule: "daily", target_size: 2},
        test2: {active_in: "none", schedule: "daily", target_size: 2},
        test3: {active_in: ["development", "test"], schedule: "daily", target_size: 2},
        test4: {active_in: "all", schedule: "daily", target_size: {size: 2, strategy: "exact_size"}},
        test5: {active_in: "all", schedule: "daily", target_size: {size: 2, strategy: "flexible_size"}},
        test6: {active_in: "all", schedule: "weekly", target_size: 2},
        test7: {active_in: "all", schedule: "fortnightly", target_size: 2},
        test8: {active_in: "all", schedule: "monthly", target_size: 2}
      }

      assert Config.new(config)
    end

    test "raises for invalid string active_in" do
      config = {test: {active_in: "invalid", schedule: "daily", target_size: 2}}

      error = assert_raises(InvalidMatchmakingConfig) {
        Config.new(config)
      }
      assert_equal :active_in, error.field
      assert_equal "must be 'all', 'none', or an array of environment strings", error.message
    end

    test "raises for invalid array active_in" do
      config = {test: {active_in: [1, 2, 3], schedule: "daily", target_size: 2}}

      error = assert_raises(InvalidMatchmakingConfig) {
        Config.new(config)
      }
      assert_equal :active_in, error.field
      assert_equal "must be 'all', 'none', or an array of environment strings", error.message
    end

    test "raises for invalid schedule" do
      config = {test: {active_in: "all", schedule: "invalid", target_size: 2}}

      error = assert_raises(InvalidMatchmakingConfig) {
        Config.new(config)
      }
      assert_equal :schedule, error.field
      assert_equal "must be 'daily', 'weekly', 'fortnightly', or 'monthly'", error.message
    end

    test "raises for non-hash or integer target_size" do
      config = {test: {active_in: "all", schedule: "daily", target_size: nil}}

      error = assert_raises(InvalidMatchmakingConfig) {
        Config.new(config)
      }
      assert_equal :target_size, error.field
      assert_equal "must be an integer or a hash", error.message
    end

    test "raises for invalid integer target_size" do
      config = {test: {active_in: "all", schedule: "daily", target_size: -1}}

      error = assert_raises(InvalidMatchmakingConfig) {
        Config.new(config)
      }
      assert_equal :target_size, error.field
      assert_equal "must be a positive integer", error.message
    end

    test "raises for invalid hash target_size" do
      config = {test: {active_in: "all", schedule: "daily", target_size: {size: "invalid", strategy: "invalid"}}}

      error = assert_raises(InvalidMatchmakingConfig) {
        Config.new(config)
      }
      assert_equal :target_size, error.field
      assert_equal "must be a hash with a size and a strategy of 'exact_size' or 'flexible_size'", error.message
    end

    test "#has_group? returns true if group exists" do
      config = {test: {active_in: "all", schedule: "daily", target_size: 2}}

      assert Config.new(config).has_group?(:test)
    end

    test "#has_group? returns false if group does not exist" do
      config = {test: {active_in: "all", schedule: "daily", target_size: 2}}

      refute Config.new(config).has_group?(:other)
    end

    test "#groups returns a list of MatchmakingGroup objects" do
      config = {
        active_in_all: {active_in: "all", schedule: "daily", target_size: 2, slack_channel: "test-1"},
        active_in_none: {active_in: "none", schedule: "daily", target_size: 2, slack_channel: "test-2"},
        active_in_list: {active_in: ["development", "test"], schedule: "monthly", target_size: 2, slack_channel: "test-3"},
        target_size_exact: {active_in: "all", schedule: "daily", target_size: {size: 2, strategy: "exact_size"}, slack_channel: "test-4"},
        target_size_flexible: {active_in: "all", schedule: "daily", target_size: {size: 3, strategy: "flexible_size"}, slack_channel: "test-5"},
        weekly: {active_in: "all", schedule: "weekly", target_size: 2, slack_channel: "test-6"},
        fortnightly: {active_in: "all", schedule: "fortnightly", target_size: 2, slack_channel: "test-7"},
        monthly: {active_in: "all", schedule: "monthly", target_size: 2, slack_channel: "test-8"}
      }

      groups = Config.new(config).groups

      assert_equal 8, groups.size
      assert groups.all? { |group| group.is_a?(MatchmakingGroup) }

      assert group_match?(groups[0], name: "active_in_all", slack_channel_name: "test-1", schedule: "daily", target_size: 2, is_active: true, size_strategy: "flexible_size")
      assert group_match?(groups[1], name: "active_in_none", slack_channel_name: "test-2", schedule: "daily", target_size: 2, is_active: false, size_strategy: "flexible_size")
      assert group_match?(groups[2], name: "active_in_list", slack_channel_name: "test-3", schedule: "monthly", target_size: 2, is_active: true, size_strategy: "flexible_size")
      assert group_match?(groups[3], name: "target_size_exact", slack_channel_name: "test-4", schedule: "daily", target_size: 2, is_active: true, size_strategy: "exact_size")
      assert group_match?(groups[4], name: "target_size_flexible", slack_channel_name: "test-5", schedule: "daily", target_size: 3, is_active: true, size_strategy: "flexible_size")
      assert group_match?(groups[5], name: "weekly", slack_channel_name: "test-6", schedule: "weekly", target_size: 2, is_active: true, size_strategy: "flexible_size")
      assert group_match?(groups[6], name: "fortnightly", slack_channel_name: "test-7", schedule: "fortnightly", target_size: 2, is_active: true, size_strategy: "flexible_size")
      assert group_match?(groups[7], name: "monthly", slack_channel_name: "test-8", schedule: "monthly", target_size: 2, is_active: true, size_strategy: "flexible_size")
    end

    def group_match?(group, expected)
      group.name == expected[:name] &&
        group.slack_channel_name == expected[:slack_channel_name] &&
        group.schedule == expected[:schedule] &&
        group.target_size == expected[:target_size] &&
        group.is_active == expected[:is_active] &&
        group.size_strategy == expected[:size_strategy] &&
        group.readonly?
    end
  end
end
