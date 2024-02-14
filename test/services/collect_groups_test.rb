require "test_helper"

class CollectGroupsTest < ActiveSupport::TestCase
  setup do
    @subject = CollectGroups
    @config = build_config(
      test1: {active: true, size: 2, channel: "group-test1", schedule: :daily},
      test2: {active: true, size: 3, channel: "group-test2", schedule: :daily},
      test3: {active: true, size: 4, channel: "group-test3", schedule: :daily}
    )
  end

  test "no database records" do
    service = @subject.new(config: @config)

    groups = service.call

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
    service = @subject.new(config: @config)

    groups = service.call

    assert_equal 4, groups.size
    assert_equal custom_group, groups.last
  end

  private

  def build_config(hash = {})
    group_defaults = {size: 2, active: true, schedule: :weekly, channel: "test-channel"}

    normalized = hash.map do |group, group_config|
      [group, OpenStruct.new(group_config.reverse_merge(group_defaults).slice(:size, :active, :schedule, :channel))]
    end.to_h

    OpenStruct.new(normalized)
  end
end
