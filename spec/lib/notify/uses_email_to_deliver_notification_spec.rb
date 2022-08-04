require "rails_helper"

RSpec.describe Notify::UsesEmailToDeliverNotification do
  let(:config) { OpenStruct.new(test: OpenStruct.new(channel: "test")) }
  let(:subject) { Notify::UsesEmailToDeliverNotification.new(config: config) }

  before(:example) do
    @retrieves_slack_user_info = double(Slack::RetrievesSlackUserInfo)
    @builds_grouping_mailer_message = double(Mailer::BuildsGroupingMailerMessage)

    allow(Slack::RetrievesSlackUserInfo).to receive(:new) { @retrieves_slack_user_info }
    allow(Mailer::BuildsGroupingMailerMessage).to receive(:new) { @builds_grouping_mailer_message }
  end

  it "sends an email to all members" do
    mailer = double(GroupingMailer)

    notification = PendingNotification.new(strategy: "email")
    create_historical_match(
      grouping: "test",
      members: ["USER_ID_1", "USER_ID_2"],
      pending_notifications: [notification]
    )

    expect(@retrieves_slack_user_info).to receive(:call)
      .with(user: "USER_ID_1") {
        Slack::Messages::Message.new(
          id: "USER_ID_1",
          profile: Slack::Messages::Message.new(real_name: "Luke", email: "luke@rebels.com")
        )
      }
    expect(@retrieves_slack_user_info).to receive(:call)
      .with(user: "USER_ID_2") {
        Slack::Messages::Message.new(
          id: "USER_ID_2",
          profile: Slack::Messages::Message.new(real_name: "Leia", email: "leia@rebels.com")
        )
      }
    expect(@builds_grouping_mailer_message).to receive(:render)
      .with(
        recipient: Mailer::MatchMember.new(name: "Luke", email: "luke@rebels.com"),
        channel: "test",
        grouping: "test",
        other_members: [
          Mailer::MatchMember.new(name: "Leia", email: "leia@rebels.com")
        ]
      ) { mailer }
    expect(@builds_grouping_mailer_message).to receive(:render)
      .with(
        recipient: Mailer::MatchMember.new(name: "Leia", email: "leia@rebels.com"),
        channel: "test",
        grouping: "test",
        other_members: [
          Mailer::MatchMember.new(name: "Luke", email: "luke@rebels.com")
        ]
      ) { mailer }
    expect(mailer).to receive(:deliver_now).twice

    subject.call(notification: notification)
  end

  it "does not send an email if the strategy is not email" do
    notification = PendingNotification.new(strategy: "slack")
    create_historical_match(
      grouping: "test",
      members: ["USER_ID_1", "USER_ID_2"],
      pending_notifications: [notification]
    )

    expect(@retrieves_slack_user_info).to_not receive(:call)
    expect(@builds_grouping_mailer_message).to_not receive(:render)

    subject.call(notification: notification)
  end
end
