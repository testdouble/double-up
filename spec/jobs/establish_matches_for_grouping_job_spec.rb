require "rails_helper"

RSpec.describe EstablishMatchesForGroupingJob do
  let(:config) { OpenStruct.new(test: OpenStruct.new(size: 2, channel: "group-test")) }
  let(:seed) { 98765 }

  before(:example) do
    srand(seed)

    @loads_slack_channels = double(Slack::LoadsSlackChannels)
    @loads_slack_channel_members = double(Slack::LoadsSlackChannelMembers)
    @notifies_grouping_members = double(NotifiesGroupingMembers)

    allow(Slack::LoadsSlackChannels).to receive(:new) { @loads_slack_channels }
    allow(Slack::LoadsSlackChannelMembers).to receive(:new) { @loads_slack_channel_members }
    allow(NotifiesGroupingMembers).to receive(:new) { @notifies_grouping_members }
  end

  it "raises error when grouping has no associated config" do
    expect {
      EstablishMatchesForGroupingJob.new(config: config).perform(grouping: "unknown")
    }.to raise_error("No config found for grouping 'unknown'").and(change(HistoricalMatch, :count).by(0))
  end

  it "raises error when grouping has no associated config" do
    config_without_channel = OpenStruct.new(test: OpenStruct.new(size: 2))

    expect {
      EstablishMatchesForGroupingJob.new(config: config_without_channel).perform(grouping: "test")
    }.to raise_error("No configured channel for grouping 'test'").and(change(HistoricalMatch, :count).by(0))
  end

  it "matches members of a specific channel and notifies each match" do
    expect(@loads_slack_channels).to receive(:call).with(types: "public_channel") {
      [
        Slack::Messages::Message.new(id: "CHANNEL_ID_1", name: "general"),
        Slack::Messages::Message.new(id: "CHANNEL_ID_2", name: "group-test"),
        Slack::Messages::Message.new(id: "CHANNEL_ID_3", name: "random")
      ]
    }
    expect(@loads_slack_channel_members).to receive(:call).with(channel: "CHANNEL_ID_2") {
      ["USER_ID_1", "USER_ID_2", "USER_ID_3", "USER_ID_4", "USER_ID_5"]
    }
    expect(@notifies_grouping_members).to receive(:call)
      .with(grouping: "test", members: ["USER_ID_2", "USER_ID_3", "USER_ID_4"], channel_name: "group-test")
    expect(@notifies_grouping_members).to receive(:call)
      .with(grouping: "test", members: ["USER_ID_1", "USER_ID_5"], channel_name: "group-test")

    expect {
      EstablishMatchesForGroupingJob.new(config: config).perform(grouping: "test")
    }.to change(HistoricalMatch, :count).by(2)
  end
end
