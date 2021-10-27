require "rails_helper"

RSpec.describe Slack::LoadsSlackChannels do
  let(:subject) { Slack::LoadsSlackChannels.new }

  before(:example) do
    @slack_client = double(Slack::Web::Client)
    allow(Slack::ClientWrapper).to receive(:client) { @slack_client }
  end

  it "loads all active channels by types" do
    slack_public_channel = Slack::Messages::Message.new(
      id: "PUBLIC_CHANNEL_ID_1",
      is_channel: true
    )
    slack_mpim_channel = Slack::Messages::Message.new(
      id: "MPIM_CHANNEL_ID",
      is_mpim: true,
      user: Slack::Messages::Message.new(id: "USER_ID")
    )
    archived_slack_public_channel = Slack::Messages::Message.new(
      id: "PUBLIC_CHANNEL_ID_2",
      is_channel: true,
      is_archived: true
    )

    expect(@slack_client).to receive(:conversations_list).with(types: "public_channel,mpim", limit: 1000) {
      Slack::Messages::Message.new(ok: true, channels: [
        slack_public_channel,
        slack_mpim_channel,
        archived_slack_public_channel
      ])
    }

    channels = subject.call(types: "public_channel,mpim")

    expect(channels).to eq([slack_public_channel, slack_mpim_channel])
  end

  it "ignores unrecognized channel types" do
    slack_public_channel = Slack::Messages::Message.new(
      id: "PUBLIC_CHANNEL_ID_1",
      is_channel: true
    )

    expect(@slack_client).to receive(:conversations_list).with(types: "public_channel", limit: 1000) {
      Slack::Messages::Message.new(ok: true, channels: [slack_public_channel])
    }

    channels = subject.call(types: "public_channel,non_existent")

    expect(channels).to eq([slack_public_channel])
  end
end
