require "rails_helper"

RSpec.describe Auth::SendsLoginLink do
  let(:subject) { Auth::SendsLoginLink.new }

  before(:example) do
    @finds_or_creates_user = double(Auth::FindsOrCreatesUser)
    @generates_token = double(Auth::GeneratesToken)
    @builds_login_slack_message = double(Slack::BuildsLoginSlackMessage)
    @opens_slack_conversation = double(Slack::OpensSlackConversation)
    @sends_slack_message = double(Slack::SendsSlackMessage)

    allow(Auth::FindsOrCreatesUser).to receive(:new) { @finds_or_creates_user }
    allow(Auth::GeneratesToken).to receive(:new) { @generates_token }
    allow(Slack::BuildsLoginSlackMessage).to receive(:new) { @builds_login_slack_message }
    allow(Slack::OpensSlackConversation).to receive(:new) { @opens_slack_conversation }
    allow(Slack::SendsSlackMessage).to receive(:new) { @sends_slack_message }
  end

  it "does not send if a user could not be found or created" do
    expect(@finds_or_creates_user).to receive(:call).with("NONE") { nil }
    expect(@generates_token).to_not receive(:call)

    subject.call(slack_user_id: "NONE")
  end

  it "generates a token and sends a message to the slack user" do
    user = User.create(slack_user_id: "USER")
    token = "z" * 22

    expect(@finds_or_creates_user).to receive(:call).with("USER") { user }
    expect(@generates_token).to receive(:call).with(user) { token }
    expect(@builds_login_slack_message).to receive(:render).with(user: user) { [] }
    expect(@opens_slack_conversation).to receive(:call).with(users: ["USER"]) { "DM_ID" }
    expect(@sends_slack_message).to receive(:call).with(channel: "DM_ID", blocks: [])

    subject.call(slack_user_id: "USER")
  end
end
