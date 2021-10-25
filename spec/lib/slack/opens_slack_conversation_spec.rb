require "rails_helper"

RSpec.describe Slack::OpensSlackConversation do
  let(:subject) { Slack::OpensSlackConversation.new }

  before(:example) do
    @slack_client = double(Slack::Web::Client)
    allow(Slack::ClientWrapper).to receive(:client) { @slack_client }
  end

  it "opens a conversation for a group of users" do
    slack_user_ids = ["USER_ID_1", "USER_ID_2", "USER_ID_3"]
    slack_channel = Slack::Messages::Message.new(id: "MPIM_ID")

    expect(@slack_client).to receive(:conversations_open).with(users: slack_user_ids.join(",")) {
      Slack::Messages::Message.new(ok: true, channel: slack_channel)
    }

    channel = subject.call(users: slack_user_ids)

    expect(channel).to eq(slack_channel.id)
  end
end
