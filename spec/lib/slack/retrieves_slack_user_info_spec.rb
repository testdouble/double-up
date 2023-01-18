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
      Slack::Messages::Message.new(ok: true, user: {
        id: slack_user,
        profile: Slack::Messages::Message.new(real_name: "Luke", image_512: "https://example.com/x/512/512")
      })
    }

    user_info = subject.call(user: slack_user)

    expect(user_info.id).to eq(slack_user)
  end

  it "stores some user profile information to the database" do
    slack_user = "USER_ID"

    expect(@slack_client).to receive(:users_info).with(user: "USER_ID") {
      Slack::Messages::Message.new(ok: true, user: {
        id: slack_user,
        profile: Slack::Messages::Message.new(real_name: "Luke", image_512: "https://example.com/x/512/512")
      })
    }

    expect {
      subject.call(user: slack_user)
    }.to change {
      SlackUserProfile.find_by(slack_user_id: slack_user)
    }.from(NilClass)
  end
end
