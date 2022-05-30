require "rails_helper"

RSpec.describe Notify::DeterminesRetriability do
  let(:subject) { Notify::DeterminesRetriability.new }

  context "daily schedule" do
    it "returns :noretry when today is saturday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 5) }

      result = subject.call(:daily, original_date: Date.civil(2022, 3, 5))

      expect(result).to eq(:noretry)
    end

    it "returns :noretry when today is sunday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 6) }

      result = subject.call(:daily, original_date: Date.civil(2022, 3, 6))

      expect(result).to eq(:noretry)
    end

    it "returns :retry if today is the same date as original date and a weekday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 7) }

      result = subject.call(:daily, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:retry)
    end

    it "returns :noretry if the original date is different than today" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 8) }

      result = subject.call(:daily, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:noretry)
    end
  end

  context ":weekly" do
    it "returns :noretry when today is saturday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 5) }

      result = subject.call(:weekly, original_date: Date.civil(2022, 3, 4))

      expect(result).to eq(:noretry)
    end

    it "returns :noretry when today is sunday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 6) }

      result = subject.call(:weekly, original_date: Date.civil(2022, 3, 4))

      expect(result).to eq(:noretry)
    end

    it "returns :retry if today is the same date as the original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 7) }

      result = subject.call(:weekly, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:retry)
    end

    it "returns :retry if today is the day after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 8) }

      result = subject.call(:weekly, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:retry)
    end

    it "returns :retry if today is 2 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 9) }

      result = subject.call(:weekly, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:retry)
    end

    it "returns :retry if today is 3 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 10) }

      result = subject.call(:weekly, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:retry)
    end

    it "returns :noretry if today is 4 days or later after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 11) }

      result = subject.call(:weekly, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:noretry)
    end
  end

  context ":fortnightly" do
    it "returns :noretry when today is saturday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 5) }

      result = subject.call(:fortnightly, original_date: Date.civil(2022, 3, 4))

      expect(result).to eq(:noretry)
    end

    it "returns :noretry when today is sunday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 6) }

      result = subject.call(:fortnightly, original_date: Date.civil(2022, 3, 4))

      expect(result).to eq(:noretry)
    end

    it "returns :retry if today is the same date as the original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 7) }

      result = subject.call(:fortnightly, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:retry)
    end

    it "returns :retry if today is the day after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 8) }

      result = subject.call(:fortnightly, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:retry)
    end

    it "returns :retry if today is 2 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 9) }

      result = subject.call(:fortnightly, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:retry)
    end

    it "returns :retry if today is 7 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 14) }

      result = subject.call(:fortnightly, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:retry)
    end

    it "returns :retry if today is 8 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 15) }

      result = subject.call(:fortnightly, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:noretry)
    end
  end

  context ":monthly" do
    it "returns :noretry when today is saturday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 5) }

      result = subject.call(:monthly, original_date: Date.civil(2022, 3, 4))

      expect(result).to eq(:noretry)
    end

    it "returns :noretry when today is sunday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 6) }

      result = subject.call(:monthly, original_date: Date.civil(2022, 3, 4))

      expect(result).to eq(:noretry)
    end

    it "returns :retry if today is the same date as the original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 7) }

      result = subject.call(:monthly, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:retry)
    end

    it "returns :retry if today is the day after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 8) }

      result = subject.call(:monthly, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:retry)
    end

    it "returns :retry if today is 2 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 9) }

      result = subject.call(:monthly, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:retry)
    end

    it "returns :retry if today is 15 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 22) }

      result = subject.call(:monthly, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:retry)
    end

    it "returns :retry if today is 16 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 23) }

      result = subject.call(:monthly, original_date: Date.civil(2022, 3, 7))

      expect(result).to eq(:noretry)
    end
  end

  context "no match" do
    it "raises an ArgumentError" do
      expect {
        subject.call(:unknown, original_date: Date.civil(2021, 1, 1))
      }.to raise_error(ArgumentError).with_message("Unable to determine remaining retries for 'unknown'")
    end
  end
end
