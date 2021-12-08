require "rails_helper"

RSpec.describe NotifiesGroupingMembers do
  let(:subject) { NotifiesGroupingMembers.new }

  before(:example) do
    @opens_slack_conversation = double(Slack::OpensSlackConversation)
    @sends_slack_message = double(Slack::SendsSlackMessage)
    @builds_grouping_slack_message = double(Slack::BuildsGroupingSlackMessage)

    allow(Slack::OpensSlackConversation).to receive(:new) { @opens_slack_conversation }
    allow(Slack::SendsSlackMessage).to receive(:new) { @sends_slack_message }
    allow(Slack::BuildsGroupingSlackMessage).to receive(:new) { @builds_grouping_slack_message }
  end

  it "sends a single group slack message to all members" do
    expect(@opens_slack_conversation).to receive(:call)
      .with(users: ["USER_ID_1", "USER_ID_2"]) { "MPIM_ID" }
    expect(@builds_grouping_slack_message).to receive(:render)
      .with(grouping: "test", members: ["USER_ID_1", "USER_ID_2"], channel_name: "test") { [] }
    expect(@sends_slack_message).to receive(:call).with(channel: "MPIM_ID", blocks: [])

    subject.call(grouping: "test", members: ["USER_ID_1", "USER_ID_2"], channel_name: "test")
  end
end
