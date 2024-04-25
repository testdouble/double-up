require "test_helper"

class CollectGroupsTest < ActiveSupport::TestCase
  setup do
    @groups = [
      group_with(name: "test1", target_size: 2, slack_channel_name: "group-test1", schedule: :daily),
      group_with(name: "test2", target_size: 3, slack_channel_name: "group-test2", schedule: :daily),
      group_with(name: "test3", target_size: 4, slack_channel_name: "group-test3", schedule: :daily)
    ]

    stub_matchmaking_config(@groups) do
      @subject = CollectGroups.new
    end
  end

  test "no database records" do
    groups = @subject.call

    assert_equal 3, groups.size
    assert groups.all? { |group| group.is_a?(MatchmakingGroup) }
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
