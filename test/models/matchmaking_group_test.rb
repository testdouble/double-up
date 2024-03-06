require "test_helper"

class MatchmakingGroupTest < ActiveSupport::TestCase
  setup do
    @groups = [
      group_with(name: "test1", target_size: 2, slack_channel_name: "group-test1", schedule: :daily),
      group_with(name: "test2", target_size: 3, slack_channel_name: "group-test2", schedule: :daily),
      group_with(name: "test3", target_size: 4, slack_channel_name: "group-test3", schedule: :daily)
    ]

    @subject = MatchmakingGroup
  end

  test "requires unique name" do
    stub_matchmaking_config(@groups) do
      create_matchmaking_group(name: "test")
      group = @subject.new(name: "test")
      assert group.invalid?
      assert_equal group.errors[:name].first, "has already been taken"
    end
  end

  test "prevents name clashes with matchmaking config" do
    stub_matchmaking_config(@groups) do |config|
      stubs { config.has_group?("test1") }.with { true }

      group = @subject.new(name: "test1")
      assert group.invalid?
      assert_equal group.errors[:name].first, "cannot be the same as a key in the matchmaking config"
    end
  end

  test "creates successfully" do
    stub_matchmaking_config(@groups) do
      group = @subject.new(
        name: "test",
        slack_channel_name: "test-channel",
        schedule: "daily",
        target_size: 2,
        is_active: true,
        slack_user_id: "42"
      )

      assert group.valid?
      assert group.errors.empty?
    end
  end

  test ".name_exists? returns true if name exists in matchmaking config" do
    stub_matchmaking_config(@groups) do |config|
      stubs { config.has_group?("test1") }.with { true }

      assert @subject.name_exists?("test1")
    end
  end

  test ".name_exists? returns true if name exists in database" do
    stub_matchmaking_config(@groups) do |config|
      stubs { config.has_group?("test") }.with { false }

      create_matchmaking_group(name: "test")
      assert @subject.name_exists?("test")
    end
  end

  test ".name_exists? returns false if name does not exist in matchmaking config or database" do
    stub_matchmaking_config(@groups) do |config|
      stubs { config.has_group?("test") }.with { false }

      assert_not @subject.name_exists?("test")
    end
  end

  test "#size_strategy returns default size strategy" do
    group = @subject.new
    assert_equal group.size_strategy, "flexible_size"
  end

  test "#size_strategy= sets size strategy" do
    group = @subject.new
    group.size_strategy = "exact_size"
    assert_equal group.size_strategy, "exact_size"
  end

  test "#flexible_size? returns true if size strategy is flexible" do
    group = @subject.new
    assert group.flexible_size?
  end

  test "#exact_size? returns true if size strategy is exact" do
    group = @subject.new
    group.size_strategy = "exact_size"
    assert group.exact_size?
  end
end
