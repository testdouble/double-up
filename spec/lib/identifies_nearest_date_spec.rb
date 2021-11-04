require "rails_helper"

RSpec.describe IdentifiesNearestDate do
  let(:subject) { IdentifiesNearestDate.new }

  context ":daily" do
    it "returns the date when it is a weekday" do
      date = subject.call(:daily, from: Date.civil(2021, 8, 18))

      expect(date).to eq(Date.civil(2021, 8, 18))
    end

    it "returns the next monday when the date is not a weekday" do
      date = subject.call(:daily, from: Date.civil(2021, 5, 15))

      expect(date).to eq(Date.civil(2021, 5, 17))
    end
  end

  context ":weekly" do
    it "returns the date when it is monday" do
      date = subject.call(:weekly, from: Date.civil(2021, 1, 4))

      expect(date).to eq(Date.civil(2021, 1, 4))
    end

    it "returns the next monday when the date is not monday" do
      date = subject.call(:weekly, from: Date.civil(2021, 1, 5))

      expect(date).to eq(Date.civil(2021, 1, 11))
    end
  end

  context ":monthly" do
    it "returns the date when it is the first monday of the month" do
      date = subject.call(:monthly, from: Date.civil(2021, 4, 5))

      expect(date).to eq(Date.civil(2021, 4, 5))
    end

    it "returns the first monday of the current month when date is before" do
      date = subject.call(:monthly, from: Date.civil(2021, 4, 1))

      expect(date).to eq(Date.civil(2021, 4, 5))
    end

    it "returns the first monday of the next month when date is after" do
      date = subject.call(:monthly, from: Date.civil(2021, 4, 6))

      expect(date).to eq(Date.civil(2021, 5, 3))
    end
  end

  context ":fortnightly" do
    it "returns the date when it is monday on an odd numbered week" do
      date = subject.call(:fortnightly, from: Date.civil(2021, 1, 18))

      expect(date).to eq(Date.civil(2021, 1, 18))
    end

    it "returns the next monday on an odd numbered week when date is not on an odd numbered monday" do
      date = subject.call(:fortnightly, from: Date.civil(2021, 1, 19))

      expect(date).to eq(Date.civil(2021, 2, 1))
    end
  end

  context "no match" do
    it "raises an ArgumentError" do
      expect {
        subject.call(:unknown, from: Date.civil(2021, 1, 1))
      }.to raise_error(ArgumentError).with_message("No matching schedule for 'unknown'")
    end
  end
end
