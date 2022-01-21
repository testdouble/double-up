require "rails_helper"

RSpec.describe Matchmaking::UpdatesParticipantAvailability, type: :matchmaking do
  let(:config) { OpenStruct.new(test: OpenStruct.new(channel: "testing")) }
  subject { Matchmaking::UpdatesParticipantAvailability.new(config: config) }

  context "When setting a member availability to unavailable" do
    let(:availability) { "unavailable" }

    it "should store a new grouping_member_availability" do
      expect {
        subject.call(slack_channel: "testing", member_id: "USER_1", availability: availability)
      }.to change(GroupingMemberAvailability.unavailable, :count).by(1)
    end
  end

  context "When setting a member availability to available" do
    let(:availability) { "available" }

    it "should not store anything new (no availability records implies available)" do
      expect {
        subject.call(slack_channel: "testing", member_id: "USER_1", availability: availability)
      }.to change(GroupingMemberAvailability, :count).by(0)
    end
  end

  context "When setting an unavailable member availability to available" do
    let(:availability) { "available" }

    before do
      create_grouping_member_availability(grouping: "test", member_id: "USER_1", availability: "unavailable")
    end

    it "should update member to be available again" do
      expect {
        subject.call(slack_channel: "testing", member_id: "USER_1", availability: availability)
      }.to change(GroupingMemberAvailability.unavailable, :count).by(-1)
    end
  end

  context "When an invalid channel is received" do
    it "raises an error" do
      expect {
        subject.call(slack_channel: "invalid", member_id: "U12345678", availability: "available")
      }.to raise_error(ArgumentError, /No matching grouping for channel/)
    end
  end

  context "When an invalid availability is received" do
    it "raises an error" do
      expect {
        subject.call(slack_channel: "testing", member_id: "U12345678", availability: "ready_soon")
      }.to raise_error(ArgumentError, /Unrecognized availability/)
    end
  end
end
