module Chatops
  class HandlesSlashCommand
    def call(slash_command)
      case slash_command.text
      when "available", "unavailable"
        Matchmaking::UpdatesParticipantAvailability.new.call(
          slack_channel: slash_command.channel_name,
          member_id: slash_command.user_id,
          availability: slash_command.text
        )
        "Success"
      else
        "pong"
      end
    end
  end
end
