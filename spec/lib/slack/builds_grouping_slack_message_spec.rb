require "rails_helper"

RSpec.describe Slack::BuildsGroupingSlackMessage do
  let(:config) {
    OpenStruct.new(
      test: OpenStruct.new(channel: "group-test"),
      rotating_brunch: OpenStruct.new(channel: "rotating-brunch")
    )
  }
  let(:subject) { Slack::BuildsGroupingSlackMessage.new(config: config) }

  it "renders message as blocks with 2 members" do
    match = create_historical_match(grouping: "test", members: ["USER_ID_1", "USER_ID_2"])

    content = subject.render(match: match)

    expect(content).to eq([
      {type: "section", text: {type: "mrkdwn", text: <<~MSG.chomp}}
        :wave: Hi <@USER_ID_1> and <@USER_ID_2>! You've been matched up for Test from #group-test! Find a time to meet, and have fun!
      MSG
    ])
  end

  it "renders message as blocks with 3 members" do
    match = create_historical_match(grouping: "test", members: ["USER_ID_1", "USER_ID_2", "USER_ID_3"])

    content = subject.render(match: match)

    expect(content).to eq([
      {type: "section", text: {type: "mrkdwn", text: <<~MSG.chomp}}
        :wave: Hi <@USER_ID_1>, <@USER_ID_2> and <@USER_ID_3>! You've been matched up for Test from #group-test! Find a time to meet, and have fun!
      MSG
    ])
  end

  it "renders message with humanized grouping name" do
    match = create_historical_match(grouping: "rotating_brunch", members: ["USER_ID_1", "USER_ID_2"])

    content = subject.render(match: match)

    expect(content).to eq([
      {type: "section", text: {type: "mrkdwn", text: <<~MSG.chomp}}
        :wave: Hi <@USER_ID_1> and <@USER_ID_2>! You've been matched up for Rotating Brunch from #rotating-brunch! Find a time to meet, and have fun!
      MSG
    ])
  end
end
