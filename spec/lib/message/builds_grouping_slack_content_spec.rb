require "rails_helper"

RSpec.describe Message::BuildsGroupingSlackContent do
  let(:subject) { Message::BuildsGroupingSlackContent.new }

  it "renders message as blocks with 2 members" do
    content = subject.render(
      grouping: "test",
      members: ["USER_ID_1", "USER_ID_2"],
      channel_name: "group-test"
    )

    expect(content).to eq([
      {type: "section", text: {type: "mrkdwn", text: <<~MSG.chomp}}
        :wave: Hi <@USER_ID_1> and <@USER_ID_2>! You've been matched up for test from #group-test! Find a time to meet, and have fun!
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
        :wave: Hi <@USER_ID_1>, <@USER_ID_2> and <@USER_ID_3>! You've been matched up for test from #group-test! Find a time to meet, and have fun!
      MSG
    ])
  end
end
