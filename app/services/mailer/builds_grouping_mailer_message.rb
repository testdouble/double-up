module Mailer
  class BuildsGroupingMailerMessage
    def render(recipient:, channel:, grouping:, other_members:)
      GroupingMailer.encourage_match(
        recipient: recipient,
        mailer_params: GroupingMailerParameters.new(
          channel: channel,
          grouping: grouping,
          other_members: other_members
        )
      )
    end
  end
end
