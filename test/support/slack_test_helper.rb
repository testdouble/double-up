module SlackTestHelper
  def stub_slack_client(&block)
    client = Mocktail.of(Slack::Web::Client)
    Slack::ClientWrapper.stub :client, client do
      block.call(client)
    end
  end

  def assert_blocks_match(expected, actual)
    assert_equal expected.to_json, actual.to_json
  end
end
