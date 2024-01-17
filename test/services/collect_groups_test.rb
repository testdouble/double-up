require "test_helper"

class CollectGroupsTest < ActiveSupport::TestCase
  setup do
    @subject = CollectGroups
    @config = matchmaking_config(
      test1: {active: true, size: 2, channel: "group-test1", schedule: :daily},
      test2: {active: true, size: 3, channel: "group-test2", schedule: :daily},
      test3: {active: true, size: 4, channel: "group-test3", schedule: :daily}
    )
  end

  test "no database records" do
    service = @subject.new(config: @config)

    groups = service.call

    assert_equal 3, groups.to_h.size
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
    service = @subject.new(config: @config)

    groups = service.call

    assert_equal 4, groups.to_h.size
    assert_equal(
      {
        id: custom_group.id,
        active: true,
        size: 2,
        channel: "custom-group",
        schedule: :weekly,
        readonly: false
      },
      groups.database_record.to_h
    )
  end
end
