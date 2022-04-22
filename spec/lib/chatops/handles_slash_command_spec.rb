require "rails_helper"

RSpec.describe Chatops::HandlesSlashCommand do
  let(:text) { "" }
  let(:slash_command) { Chatops::SlackSlashCommand.new(text: text) }

  before(:example) do
    @updates_participant_availability = double(Matchmaking::UpdatesParticipantAvailability)

    allow(Matchmaking::UpdatesParticipantAvailability).to receive(:new) { @updates_participant_availability }
  end

  context "Slash command for making member available" do
    let(:text) { "available" }

    subject { Chatops::HandlesSlashCommand.new }

    it "updates participants for valid text input" do
      expect(@updates_participant_availability).to receive(:call)

      subject.call(slash_command)
    end
  end

  context "Slash command for making member unavailable" do
    let(:text) { "unavailable" }

    subject { Chatops::HandlesSlashCommand.new }

    it "updates participants for valid text input" do
      expect(@updates_participant_availability).to receive(:call)

      subject.call(slash_command)
    end
  end

  context "Slash command when text is not a recognized command" do
    let(:text) { "ping" }

    subject { Chatops::HandlesSlashCommand.new }

    it "No updates are attempted" do
      expect(@updates_participant_availability).not_to receive(:call)

      subject.call(slash_command)
    end
  end
end
