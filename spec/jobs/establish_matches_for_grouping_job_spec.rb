require "rails_helper"

RSpec.describe EstablishMatchesForGroupingJob do
  let(:config) { OpenStruct.new(test: OpenStruct.new(size: 2, channel: "group-test")) }
  let(:seed) { 98765 }

  before(:example) do
    srand(seed)

    @loads_slack_channels = double(Slack::LoadsSlackChannels)
    @loads_slack_channel_members = double(Slack::LoadsSlackChannelMembers)
    @opens_slack_conversation = double(Slack::OpensSlackConversation)
    @sends_slack_message = double(Slack::SendsSlackMessage)

    allow(Slack::LoadsSlackChannels).to receive(:new) { @loads_slack_channels }
    allow(Slack::LoadsSlackChannelMembers).to receive(:new) { @loads_slack_channel_members }
    allow(Slack::OpensSlackConversation).to receive(:new) { @opens_slack_conversation}
    allow(Slack::SendsSlackMessage).to receive(:new) { @sends_slack_message }
  end

  it "raises error when grouping has no associated config" do
    expect {
      EstablishMatchesForGroupingJob.new(config: config).perform(grouping: "unknown")
    }.to raise_error("No config found for grouping 'unknown'")
  end

  it "raises error when grouping has no associated config" do
    config_without_channel = OpenStruct.new(test: OpenStruct.new(size: 2))

    expect {
      EstablishMatchesForGroupingJob.new(config: config_without_channel).perform(grouping: "test")
    }.to raise_error("No configured channel for grouping 'test'")
  end

  it "matches members of a specific channel and notifies each match" do
    expect(@loads_slack_channels).to receive(:call).with(types: "public_channel") {
      [
        Slack::Messages::Message.new(id: "CHANNEL_ID_1", name_normalized: "general"),
        Slack::Messages::Message.new(id: "CHANNEL_ID_2", name_normalized: "group-test"),
        Slack::Messages::Message.new(id: "CHANNEL_ID_3", name_normalized: "random")
      ]
    }
    expect(@loads_slack_channel_members).to receive(:call).with(channel: "CHANNEL_ID_2") {
      ["USER_ID_1", "USER_ID_2", "USER_ID_3", "USER_ID_4", "USER_ID_5"]
    }
    expect(@opens_slack_conversation).to receive(:call)
      .with(users: ["USER_ID_2", "USER_ID_3", "USER_ID_4"]) { "MPIM_ID_1" }
    expect(@opens_slack_conversation).to receive(:call)
      .with(users: ["USER_ID_1", "USER_ID_5"]) { "MPIM_ID_2" }
    expect(@sends_slack_message).to receive(:call).with(channel: "MPIM_ID_1", blocks: anything)
    expect(@sends_slack_message).to receive(:call).with(channel: "MPIM_ID_2", blocks: anything)

    EstablishMatchesForGroupingJob.new(config: config).perform(grouping: "test")
  end
end
