module SlackTestHelper
  def assert_blocks_match(expected, actual)
    assert_equal expected.to_json, actual.to_json
  end
end
