require "test_helper"

module Slack
  class HandleInteractionTest < ActiveSupport::TestCase
    setup do
      @historical_match = create_historical_match(grouping: "test", members: ["Frodo", "Sam"])
      ProtractedMatch.create!(historical_match: @historical_match)

      @send_response_message = Mocktail.of_next(SendResponseMessage)

      @subject_class = HandleInteraction
    end

    test "handles a quest protraction interaction" do
      payload = {
        "type" => "block_actions",
        "user" => {"id" => "Frodo"},
        "actions" => [
          {
            "action_id" => "quest_continue",
            "value" => @historical_match.id.to_s
          }
        ]
      }

      assert_changes -> { @historical_match.protracted_match.reload.last_protracted_by }, from: nil, to: "Frodo" do
        @subject_class.new(payload).call
      end

      verify { |m| @send_response_message.call(text: m.any) }
      verify { |m| @send_response_message.call(text: m.any, type: "in_channel") }
    end

    test "handles a quest completion interaction" do
      payload = {
        "type" => "block_actions",
        "user" => {"id" => "Frodo"},
        "actions" => [
          {
            "action_id" => "quest_complete",
            "value" => @historical_match.id.to_s
          }
        ]
      }

      assert_changes -> { @historical_match.protracted_match.reload.completed_by }, from: nil, to: "Frodo" do
        assert_changes -> { @historical_match.protracted_match.reload.completed_at }, from: nil do
          @subject_class.new(payload).call
        end
      end

      verify { |m| @send_response_message.call(text: m.any) }
      verify { |m| @send_response_message.call(text: m.any, type: "in_channel") }
    end

    test "handles an unknown interaction" do
      payload = {
        "type" => "block_actions",
        "user" => {"id" => "Frodo"},
        "actions" => [
          {
            "action_id" => "unknown",
            "value" => @historical_match.id.to_s
          }
        ]
      }

      @subject_class.new(payload).call

      verify { @send_response_message.call(text: "Unknown action") }
    end
  end
end
