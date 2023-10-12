require "rails_helper"

RSpec.describe CollectGroups do
  let(:config) do
    OpenStruct.new(
      test1: OpenStruct.new(active: true, size: 2, channel: "group-test1", schedule: :daily),
      test2: OpenStruct.new(active: true, size: 3, channel: "group-test2", schedule: :daily),
      test3: OpenStruct.new(active: true, size: 4, channel: "group-test3", schedule: :daily)
    )
  end

  before do
    MatchmakingGroup.create(
      name: "database_record",
      slack_channel_name: "bar",
      schedule: "weekly",
      target_size: 2,
      is_active: true,
      slack_user_id: "42"
    )
  end

  it "returns a hash that merges config and MatchmakingGroup records" do
    collect_groups = CollectGroups.new(config: config)
    result = collect_groups.call

    expect(result.size).to eq(4)

    expect(result.database_record.to_h).to contain_exactly(
      active: true,
      size: 2,
      channel: "bar",
      schedule: :weekly,
      readonly: false
    )
  end
end
