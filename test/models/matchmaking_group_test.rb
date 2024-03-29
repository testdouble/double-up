require "test_helper"

class MatchmakingGroupTest < ActiveSupport::TestCase
  setup do
    @config = {
      test1: {active: true, size: 2, channel: "group-test1", schedule: :daily},
      test2: {active: true, size: 3, channel: "group-test2", schedule: :daily},
      test3: {active: true, size: 4, channel: "group-test3", schedule: :daily}
    }

    @subject = MatchmakingGroup
  end

  test "requires unique name" do
    matchmaking_config_of(@config) do
      create_matchmaking_group(name: "test")
      group = @subject.new(name: "test")
      assert group.invalid?
      assert_equal group.errors[:name].first, "has already been taken"
    end
  end

  test "prevents name clashes with matchmaking config" do
    matchmaking_config_of(@config) do
      group = @subject.new(name: "test1")
      assert group.invalid?
      assert_equal group.errors[:name].first, "cannot be the same as a key in the matchmaking config"
    end
  end

  test "creates successfully" do
    matchmaking_config_of(@config) do
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
    matchmaking_config_of(@config) do
      assert @subject.name_exists?("test1")
    end
  end

  test ".name_exists? returns true if name exists in database" do
    matchmaking_config_of(@config) do
      create_matchmaking_group(name: "test")
      assert @subject.name_exists?("test")
    end
  end

  test ".name_exists? returns false if name does not exist in matchmaking config or database" do
    matchmaking_config_of(@config) do
      assert_not @subject.name_exists?("test")
    end
  end
end
