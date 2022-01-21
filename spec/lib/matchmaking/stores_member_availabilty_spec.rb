require "rails_helper"

RSpec.describe Matchmaking::StoresMemberAvailability, type: :matchmaking do
  let(:config) { OpenStruct.new(test: OpenStruct.new(size: 2, channel: "rotating-coffee")) }

  describe "call" do
    subject { described_class.new(config: config) }

    let(:slack_channel) { "rotating-coffee" }
    let(:slack_user_id) { "U012ABCDEF" }
    let(:availability) { "available" }

    it "does increase the availability count" do
      expect { 
        subject.call(
          slack_channel: slack_channel,
          slack_user_id: slack_user_id,
          availability: availability
        )
      }.to change(GroupingMemberAvailability, :count).by(1)
    end
  end

  describe "grouping_for_channel" do
    let(:slack_channel) { "rotating-coffee" }
    subject { described_class.new(config: config) }

    it "returns the correct slack_channel grouping" do
      expect(
        subject.send(:grouping_for_channel, slack_channel)
      ).to eq(:test)
    end
  end
end