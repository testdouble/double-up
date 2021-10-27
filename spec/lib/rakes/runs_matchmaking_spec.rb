require "rails_helper"

RSpec.describe Rakes::RunsMatchmaking do
  before(:example) do
    @stdout = StringIO.new
    @stderr = StringIO.new

    @establish_matches_for_grouping_job = double(EstablishMatchesForGroupingJob)
    allow(EstablishMatchesForGroupingJob).to receive(:new) { @establish_matches_for_grouping_job }

    @identifies_nearest_date = double(IdentifiesNearestDate)
    allow(IdentifiesNearestDate).to receive(:new) { @identifies_nearest_date }

    @jan_5 = Date.civil(2021, 1, 5)
    allow(Date).to receive(:today) { @jan_5 }
  end

  it "shows successful message" do
    expect(@identifies_nearest_date).to receive(:call).with(:daily) { @jan_5 }.exactly(3).times
    expect(@jan_5).to receive(:today?) { true }.exactly(3).times
    expect(@establish_matches_for_grouping_job).to receive(:perform).exactly(3).times

    subject = Rakes::RunsMatchmaking.new(
      stdout: @stdout, stderr: @stderr, config: OpenStruct.new(
        test1: OpenStruct.new(active: true, size: 2, channel: "group-test1", schedule: :daily),
        test2: OpenStruct.new(active: true, size: 3, channel: "group-test2", schedule: :daily),
        test3: OpenStruct.new(active: true, size: 4, channel: "group-test3", schedule: :daily)
      )
    )
    subject.call

    output = output!
    expect(output).to match(/Starting matchmaking for 'test1'/)
    expect(output).to match(/Starting matchmaking for 'test2'/)
    expect(output).to match(/Starting matchmaking for 'test3'/)
    expect(output).to match(/Matchmaking successfully completed/)
    expect(errors!).to be_empty
  end

  it "shows an error message" do
    expect(@identifies_nearest_date).to receive(:call).with(:daily) { @jan_5 }
    expect(@jan_5).to receive(:today?) { true }
    allow(@establish_matches_for_grouping_job).to receive(:perform) { raise "test" }

    subject = Rakes::RunsMatchmaking.new(
      stdout: @stdout, stderr: @stderr, config: OpenStruct.new(
        test: OpenStruct.new(active: true, size: 2, channel: "group-test", schedule: :daily)
      )
    )
    expect { subject.call }.to raise_error("test")

    output = output!
    errors = errors!
    expect(output).to match(/Starting matchmaking for 'test'/)
    expect(errors).to match(/Failed to run matchmaking for 'test'/)
  end

  it "shows inactive message" do
    expect(@identifies_nearest_date).to receive(:call).with(:daily) { @jan_5 }
    expect(@jan_5).to receive(:today?) { true }

    subject = Rakes::RunsMatchmaking.new(
      stdout: @stdout, stderr: @stderr, config: OpenStruct.new(
        test: OpenStruct.new(active: false, size: 2, channel: "group-test", schedule: :daily)
      )
    )
    subject.call

    output = output!
    expect(output).to match(/Skipping matchmaking for 'test'/)
    expect(output).to match(/Matchmaking successfully completed/)
    expect(errors!).to be_empty
  end

  it "shows completed message on an unscheduled day" do
    expect(@identifies_nearest_date).to receive(:call).with(:weekly) { @jan_5 }
    expect(@jan_5).to receive(:today?) { false }

    subject = Rakes::RunsMatchmaking.new(
      stdout: @stdout, stderr: @stderr, config: OpenStruct.new(
        test: OpenStruct.new(active: false, size: 2, channel: "group-test", schedule: :weekly)
      )
    )
    subject.call

    output = output!
    expect(output).to match(/Matchmaking successfully completed/)
    expect(errors!).to be_empty
  end

  def output!
    read_and_reset(@stdout)
  end

  def errors!
    read_and_reset(@stderr)
  end

  def read_and_reset(io)
    io.tap(&:rewind).read.tap do
      io.truncate(0)
      io.rewind
    end
  end
end
