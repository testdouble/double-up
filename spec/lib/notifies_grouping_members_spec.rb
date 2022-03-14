require "rails_helper"

RSpec.describe NotifiesGroupingMembers do
  let(:subject) { NotifiesGroupingMembers.new }

  before(:example) do
    @opens_slack_conversation = double(Slack::OpensSlackConversation)
    @sends_slack_message = double(Slack::SendsSlackMessage)
    @retrieves_slack_user_info = double(Slack::RetrievesSlackUserInfo)
    @builds_grouping_slack_message = double(Slack::BuildsGroupingSlackMessage)
    @builds_grouping_mailer_message = double(Mailer::BuildsGroupingMailerMessage)

    allow(Slack::OpensSlackConversation).to receive(:new) { @opens_slack_conversation }
    allow(Slack::SendsSlackMessage).to receive(:new) { @sends_slack_message }
    allow(Slack::RetrievesSlackUserInfo).to receive(:new) { @retrieves_slack_user_info }
    allow(Slack::BuildsGroupingSlackMessage).to receive(:new) { @builds_grouping_slack_message }
    allow(Mailer::BuildsGroupingMailerMessage).to receive(:new) { @builds_grouping_mailer_message }
  end

  it "sends a single group slack message and an email to all members" do
    mailer = double(GroupingMailer)

    expect(@opens_slack_conversation).to receive(:call)
      .with(users: ["USER_ID_1", "USER_ID_2"]) { "MPIM_ID" }
    expect(@builds_grouping_slack_message).to receive(:render)
      .with(grouping: "test", members: ["USER_ID_1", "USER_ID_2"], channel_name: "test") { [] }
    expect(@sends_slack_message).to receive(:call).with(channel: "MPIM_ID", blocks: [])
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

    subject.call(grouping: "test", members: ["USER_ID_1", "USER_ID_2"], channel_name: "test")
  end
end
