require "rails_helper"

RSpec.describe Slack::RetrievesSlackUserInfo do
  let(:subject) { Slack::RetrievesSlackUserInfo.new }

  before(:example) do
    @slack_client = double(Slack::Web::Client)
    allow(Slack::ClientWrapper).to receive(:client) { @slack_client }
  end

  it "loads a user's information from slack" do
    slack_user = "USER_ID"

    expect(@slack_client).to receive(:users_info).with(user: "USER_ID") {
      Slack::Messages::Message.new(ok: true, user: {id: slack_user})
    }

    user_info = subject.call(user: slack_user)

    expect(user_info.id).to eq(slack_user)
  end
end
