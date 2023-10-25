require "rails_helper"

RSpec.describe CollectsGroups do
  subject { CollectsGroups.new(config: yaml_config) }

  let(:yaml_config) do
    OpenStruct.new(
      test1: OpenStruct.new(active: true, size: 2, channel: "group-test1", schedule: :daily, readonly: true),
      test2: OpenStruct.new(active: true, size: 3, channel: "group-test2", schedule: :daily, readonly: true),
      test3: OpenStruct.new(active: true, size: 4, channel: "group-test3", schedule: :daily, readonly: true)
    )
  end

  it "returns only the yaml config if there are no database records" do
    result = subject.call

    expect(result.to_h.size).to eq(3)
  end

  it "returns a hash that merges config and MatchmakingGroup records" do
    MatchmakingGroup.create(
      name: "database_record",
      slack_channel_name: "bar",
      schedule: "weekly",
      target_size: 2,
      is_active: true,
      slack_user_id: "42"
    )

    result = subject.call

    expect(result.to_h.size).to eq(4)
    expect(result.database_record.to_h).to eq(
      active: true,
      size: 2,
      channel: "bar",
      schedule: :weekly,
      readonly: false
    )
  end
end
