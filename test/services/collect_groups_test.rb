require "test_helper"

class CollectGroupsTest < ActiveSupport::TestCase
  setup do
    @config = {
      test1: {active: true, size: 2, channel: "group-test1", schedule: :daily},
      test2: {active: true, size: 3, channel: "group-test2", schedule: :daily},
      test3: {active: true, size: 4, channel: "group-test3", schedule: :daily}
    }

    matchmaking_config_of(@config) do
      @subject = CollectGroups.new
    end
  end

  test "no database records" do
    groups = @subject.call

    assert_equal 3, groups.size
    assert groups.all? { |group| group.is_a?(MatchmakingGroup) && group.readonly? }
  end

  test "merges config and MatchmakingGroup records" do
    custom_group = MatchmakingGroup.create(
      name: "database_record",
      slack_channel_name: "custom-group",
      schedule: "weekly",
      target_size: 2,
      is_active: true,
      slack_user_id: "42"
    )

    groups = @subject.call

    assert_equal 4, groups.size
    assert_equal custom_group, groups.last
  end
end
