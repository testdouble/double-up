require "rails_helper"

RSpec.describe Rakes::RefreshesProfiles do
  let(:subject) { Rakes::RefreshesProfiles.new }

  before(:example) do
    @retrieves_slack_user_info = double(Slack::RetrievesSlackUserInfo)
    allow(Slack::RetrievesSlackUserInfo).to receive(:new) { @retrieves_slack_user_info }
  end

  it "creates new slack user profiles when one isn't found for a slack user id" do
    HistoricalMatch.create(grouping: "test", matched_on: Date.today, members: ["USER_ID_1", "USER_ID_2"])

    expect(@retrieves_slack_user_info).to receive(:call)
      .with(user: "USER_ID_1") {
        Slack::Messages::Message.new(
          id: "USER_ID_1",
          profile: Slack::Messages::Message.new(real_name: "Luke", image_512: "https://example.com/x/512/512")
        )
      }

    expect(@retrieves_slack_user_info).to receive(:call)
      .with(user: "USER_ID_2") {
        Slack::Messages::Message.new(
          id: "USER_ID_2",
          profile: Slack::Messages::Message.new(real_name: "Leia", image_512: "https://example.com/x/512/512")
        )
      }

    slack_user_profiles = subject.call

    expect(slack_user_profiles.sort_by(&:slack_user_id)).to eq([
      SlackUserProfile.find_by(slack_user_id: "USER_ID_1", name: "Luke", avatar_url: "https://example.com/x/512/512"),
      SlackUserProfile.find_by(slack_user_id: "USER_ID_2", name: "Leia", avatar_url: "https://example.com/x/512/512")
    ])
  end

  it "updates an existing slack user profile for a slack user id" do
    HistoricalMatch.create(grouping: "test", matched_on: Date.today, members: ["USER_ID_1", "USER_ID_2"])
    SlackUserProfile.create(slack_user_id: "USER_ID_1", name: "Luke")
    SlackUserProfile.create(slack_user_id: "USER_ID_2", name: "Leia")

    expect(@retrieves_slack_user_info).to receive(:call)
      .with(user: "USER_ID_1") {
        Slack::Messages::Message.new(
          id: "USER_ID_1",
          profile: Slack::Messages::Message.new(real_name: "Luke", image_512: "https://example.com/x/512/512")
        )
      }

    expect(@retrieves_slack_user_info).to receive(:call)
      .with(user: "USER_ID_2") {
        Slack::Messages::Message.new(
          id: "USER_ID_2",
          profile: Slack::Messages::Message.new(real_name: "Leia", image_512: "https://example.com/x/512/512")
        )
      }

    slack_user_profiles = subject.call

    expect(SlackUserProfile.count).to eq(2)
    expect(slack_user_profiles.sort_by(&:slack_user_id)).to eq([
      SlackUserProfile.find_by(slack_user_id: "USER_ID_1", name: "Luke", avatar_url: "https://example.com/x/512/512"),
      SlackUserProfile.find_by(slack_user_id: "USER_ID_2", name: "Leia", avatar_url: "https://example.com/x/512/512")
    ])
  end
end
