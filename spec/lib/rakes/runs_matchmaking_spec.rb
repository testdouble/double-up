require "rails_helper"

RSpec.describe Rakes::RunsMatchmaking do
  let(:config) {
    OpenStruct.new(
      test1: OpenStruct.new(size: 2, channel: "group-test1"),
      test2: OpenStruct.new(size: 3, channel: "group-test2"),
      test3: OpenStruct.new(size: 4, channel: "group-test3")
    )
  }

  before(:example) do
    @stdout = StringIO.new
    @stderr = StringIO.new

    @establish_matches_for_grouping_job = double(EstablishMatchesForGroupingJob)
    allow(EstablishMatchesForGroupingJob).to receive(:new) { @establish_matches_for_grouping_job }

    @subject = Rakes::RunsMatchmaking.new(stdout: @stdout, stderr: @stderr, config: config)
  end

  it "shows successful message" do
    expect(@establish_matches_for_grouping_job).to receive(:perform).exactly(3).times

    @subject.call

    output = output!
    expect(output).to match(/Starting matchmaking for 'test1'/)
    expect(output).to match(/Starting matchmaking for 'test2'/)
    expect(output).to match(/Starting matchmaking for 'test3'/)
    expect(output).to match(/Matchmaking successfully completed/)
    expect(errors!).to be_empty
  end

  it "shows successful message" do
    allow(@establish_matches_for_grouping_job).to receive(:perform) { raise "test" }

    expect { @subject.call }.to raise_error("test")

    output = output!
    errors = errors!
    expect(output).to match(/Starting matchmaking for 'test1'/)
    expect(errors).to match(/Failed to run matchmaking for 'test1'/)
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
