require "rails_helper"

RSpec.describe Matchmaking::SelectsAvailableParticipants, type: :matchmaking do
  let(:grouping) { "coffee_time" }

  subject { Matchmaking::SelectsAvailableParticipants.new(grouping: grouping) }

  it "returns empty list for no participants" do
    result = subject.call([])

    expect(result).to eq([])
  end

  context "when there are no unavailabilities" do
    it "returns all participants" do
      participant_ids = ["USER_1", "USER_2", "USER_3"]

      result = subject.call(participant_ids)

      expect(result).to eq(participant_ids)
    end
  end

  context "when there are unavailabilities for the grouping" do
    before do
      create_grouping_member_availability(grouping: grouping, member_id: "USER_3", availability: :unavailable)
    end

    it "selects only available participants" do
      participant_ids = ["USER_1", "USER_2", "USER_3"]

      result = subject.call(participant_ids)

      expect(result).to eq(["USER_1", "USER_2"])
    end
  end

  context "when there are unavailabilities for a different grouping" do
    before do
      create_grouping_member_availability(grouping: "rotating_brunch", member_id: "USER_3", availability: :unavailable)
    end

    it "should not effect participants of an unrelated grouping" do
      participant_ids = ["USER_1", "USER_2", "USER_3"]

      result = subject.call(participant_ids)

      expect(result).to eq(participant_ids)
    end
  end
end
