require "rails_helper"

RSpec.describe Notify::DeterminesRetriability do
  let(:subject) { Notify::DeterminesRetriability.new }

  context "daily schedule" do
    it "returns false when today is saturday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 5) }

      result = subject.can_retry?(:daily, original_date: Date.civil(2022, 3, 5))

      expect(result).to be false
    end

    it "returns false when today is sunday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 6) }

      result = subject.can_retry?(:daily, original_date: Date.civil(2022, 3, 6))

      expect(result).to be false
    end

    it "returns true if today is the same date as original date and a weekday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 7) }

      result = subject.can_retry?(:daily, original_date: Date.civil(2022, 3, 7))

      expect(result).to be true
    end

    it "returns false if the original date is different than today" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 8) }

      result = subject.can_retry?(:daily, original_date: Date.civil(2022, 3, 7))

      expect(result).to be false
    end
  end

  context ":weekly" do
    it "returns false when today is saturday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 5) }

      result = subject.can_retry?(:weekly, original_date: Date.civil(2022, 3, 4))

      expect(result).to be false
    end

    it "returns false when today is sunday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 6) }

      result = subject.can_retry?(:weekly, original_date: Date.civil(2022, 3, 4))

      expect(result).to be false
    end

    it "returns true if today is the same date as the original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 7) }

      result = subject.can_retry?(:weekly, original_date: Date.civil(2022, 3, 7))

      expect(result).to be true
    end

    it "returns true if today is the day after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 8) }

      result = subject.can_retry?(:weekly, original_date: Date.civil(2022, 3, 7))

      expect(result).to be true
    end

    it "returns true if today is 2 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 9) }

      result = subject.can_retry?(:weekly, original_date: Date.civil(2022, 3, 7))

      expect(result).to be true
    end

    it "returns true if today is 3 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 10) }

      result = subject.can_retry?(:weekly, original_date: Date.civil(2022, 3, 7))

      expect(result).to be true
    end

    it "returns false if today is 4 days or later after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 11) }

      result = subject.can_retry?(:weekly, original_date: Date.civil(2022, 3, 7))

      expect(result).to be false
    end
  end

  context ":fortnightly" do
    it "returns false when today is saturday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 5) }

      result = subject.can_retry?(:fortnightly, original_date: Date.civil(2022, 3, 4))

      expect(result).to be false
    end

    it "returns false when today is sunday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 6) }

      result = subject.can_retry?(:fortnightly, original_date: Date.civil(2022, 3, 4))

      expect(result).to be false
    end

    it "returns true if today is the same date as the original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 7) }

      result = subject.can_retry?(:fortnightly, original_date: Date.civil(2022, 3, 7))

      expect(result).to be true
    end

    it "returns true if today is the day after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 8) }

      result = subject.can_retry?(:fortnightly, original_date: Date.civil(2022, 3, 7))

      expect(result).to be true
    end

    it "returns true if today is 2 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 9) }

      result = subject.can_retry?(:fortnightly, original_date: Date.civil(2022, 3, 7))

      expect(result).to be true
    end

    it "returns true if today is 7 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 14) }

      result = subject.can_retry?(:fortnightly, original_date: Date.civil(2022, 3, 7))

      expect(result).to be true
    end

    it "returns false if today is 8 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 15) }

      result = subject.can_retry?(:fortnightly, original_date: Date.civil(2022, 3, 7))

      expect(result).to be false
    end
  end

  context ":monthly" do
    it "returns false when today is saturday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 5) }

      result = subject.can_retry?(:monthly, original_date: Date.civil(2022, 3, 4))

      expect(result).to be false
    end

    it "returns false when today is sunday" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 6) }

      result = subject.can_retry?(:monthly, original_date: Date.civil(2022, 3, 4))

      expect(result).to be false
    end

    it "returns true if today is the same date as the original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 7) }

      result = subject.can_retry?(:monthly, original_date: Date.civil(2022, 3, 7))

      expect(result).to be true
    end

    it "returns true if today is the day after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 8) }

      result = subject.can_retry?(:monthly, original_date: Date.civil(2022, 3, 7))

      expect(result).to be true
    end

    it "returns true if today is 2 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 9) }

      result = subject.can_retry?(:monthly, original_date: Date.civil(2022, 3, 7))

      expect(result).to be true
    end

    it "returns true if today is 15 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 22) }

      result = subject.can_retry?(:monthly, original_date: Date.civil(2022, 3, 7))

      expect(result).to be true
    end

    it "returns false if today is 16 days after original date" do
      allow(Date).to receive(:today) { Date.civil(2022, 3, 23) }

      result = subject.can_retry?(:monthly, original_date: Date.civil(2022, 3, 7))

      expect(result).to be false
    end
  end

  context "no match" do
    it "return false" do
      result = subject.can_retry?(:unknown, original_date: Date.civil(2021, 1, 1))

      expect(result).to be false
    end
  end
end
