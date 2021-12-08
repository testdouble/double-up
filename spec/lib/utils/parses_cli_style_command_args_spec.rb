require "rails_helper"

RSpec.describe Utils::ParsesCliStyleCommandArgs do
  let(:subject) { Utils::ParsesCliStyleCommandArgs.new }

  it "parses an empty string returning an empty result" do
    text = ""
    actual = subject.call(text: text)
    expected = {}
    expect(actual.subcommand).to eq(nil)
    expect(actual.args).to eq(expected)
  end

  it "parses a single first word as a downcased subcommand" do
    text = "FOO"
    actual = subject.call(text: text)

    expect(actual.subcommand).to eq("foo")
  end

  it "parses a single word after the first as a downcased key with no value" do
    text = "foo FOO"
    actual = subject.call(text: text)

    expected = {"foo" => ""}
    expect(actual.subcommand).to eq("foo")
    expect(actual.args).to eq(expected)
  end

  it "parses a single word unquoted assignment as a key and case preserved value" do
    text = "subcom foo=Bar"
    actual = subject.call(text: text)

    expected = {"foo" => "Bar"}
    expect(actual.subcommand).to eq("subcom")
    expect(actual.args).to eq(expected)
  end

  it "parses a multiple word quoted assignment as a key and multi-word value" do
    text = %(foo="bar bar bar")
    actual = subject.call(text: text)

    expected = {"foo" => "bar bar bar"}
    expect(actual.subcommand).to eq(nil)
    expect(actual.args).to eq(expected)
  end

  it "parses an assignment with a hyphen as a underscored key" do
    text = "foo-foo=bar"
    actual = subject.call(text: text)

    expected = {"foo_foo" => "bar"}
    expect(actual.subcommand).to eq(nil)
    expect(actual.args).to eq(expected)
  end

  it "ignores equal sign in quoted values" do
    text = %(foo="bar = baz")
    actual = subject.call(text: text)

    expected = {"foo" => "bar = baz"}
    expect(actual.subcommand).to eq(nil)
    expect(actual.args).to eq(expected)
  end

  it "strips hyphens from the front of the key" do
    text = "--foo=bar"
    actual = subject.call(text: text)

    expected = {"foo" => "bar"}
    expect(actual.subcommand).to eq(nil)
    expect(actual.args).to eq(expected)
  end

  it "parses multiple assignments as multiple key value pairs" do
    text = %(foo="bar bar bar" baz beep="boop boop boop")
    actual = subject.call(text: text)

    expected = {"baz" => "", "foo" => "bar bar bar", "beep" => "boop boop boop"}
    expect(actual.subcommand).to eq(nil)
    expect(actual.args).to eq(expected)
  end

  it "later assignments override earlier assignments" do
    text = %(foo="bar bar bar" beep="boop boop boop" foo="baz baz baz")
    actual = subject.call(text: text)

    expected = {"foo" => "baz baz baz", "beep" => "boop boop boop"}
    expect(actual.subcommand).to eq(nil)
    expect(actual.args).to eq(expected)
  end
end
