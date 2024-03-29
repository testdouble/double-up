require "rails_helper"

RSpec.describe Slack::BuildsGroupingSlackMessage do
  let(:subject) { Slack::BuildsGroupingSlackMessage.new }

  it "renders message as blocks with 2 members" do
    content = subject.render(
      grouping: "test",
      members: ["USER_ID_1", "USER_ID_2"],
      channel_name: "group-test"
    )

    expect(content).to eq([
      {type: "section", text: {type: "mrkdwn", text: <<~MSG.chomp}}
        :wave: Hi <@USER_ID_1> and <@USER_ID_2>! You've been matched up for Test from #group-test! Find a time to meet, and have fun!

        Run `/doubleup login` and click on a member's name for this match to see if they have set a calendar link for scheduling.
      MSG
    ])
  end

  it "renders message as blocks with 3 members" do
    content = subject.render(
      grouping: "test",
      members: ["USER_ID_1", "USER_ID_2", "USER_ID_3"],
      channel_name: "group-test"
    )

    expect(content).to eq([
      {type: "section", text: {type: "mrkdwn", text: <<~MSG.chomp}}
        :wave: Hi <@USER_ID_1>, <@USER_ID_2> and <@USER_ID_3>! You've been matched up for Test from #group-test! Find a time to meet, and have fun!
      MSG
    ])
  end

  it "renders message with humanized grouping name" do
    content = subject.render(
      grouping: "rotating_brunch",
      members: ["USER_ID_1", "USER_ID_2"],
      channel_name: "group-test"
    )

    expect(content).to eq([
      {type: "section", text: {type: "mrkdwn", text: <<~MSG.chomp}}
        :wave: Hi <@USER_ID_1> and <@USER_ID_2>! You've been matched up for Rotating Brunch from #group-test! Find a time to meet, and have fun!

        Run `/doubleup login` and click on a member's name for this match to see if they have set a calendar link for scheduling.
      MSG
    ])
  end
end
