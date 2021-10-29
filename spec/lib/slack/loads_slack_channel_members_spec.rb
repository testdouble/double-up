require "rails_helper"

RSpec.describe Slack::LoadsSlackChannelMembers do
  let(:subject) { Slack::LoadsSlackChannelMembers.new }

  before(:example) do
    @slack_client = double(Slack::Web::Client)
    allow(Slack::ClientWrapper).to receive(:client) { @slack_client }
  end

  it "loads members found in a channel" do
    slack_members = [
      "USER_ID_1",
      "USER_ID_2",
      "USER_ID_3"
    ]

    expect(@slack_client).to receive(:conversations_members).with(channel: "CHANNEL_ID", limit: 1000) {
      Slack::Messages::Message.new(ok: true, members: slack_members)
    }

    members = subject.call(channel: "CHANNEL_ID")

    expect(members).to eq(slack_members)
  end
end
