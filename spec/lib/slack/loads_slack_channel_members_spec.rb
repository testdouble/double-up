require "rails_helper"

RSpec.describe Slack::LoadsSlackChannelMembers do
  let(:subject) { Slack::LoadsSlackChannelMembers.new }

  before(:example) do
    @slack_client = double(Slack::Web::Client)
    allow(Slack::ClientWrapper).to receive(:client) { @slack_client }
  end

  it "loads members found in a channel" do
    channel = "CHANNEL_ID"
    members = [
      "USER_ID_1",
      "USER_ID_2",
      "USER_ID_3"
    ]

    expect(@slack_client).to receive(:conversations_members).with(channel: channel) {
      Slack::Messages::Message.new(ok: true, members: members)
    }

    members = subject.call(channel: channel)

    expect(members).to eq(members)
  end
end
