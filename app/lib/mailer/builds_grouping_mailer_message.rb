module Mailer
  class BuildsGroupingMailerMessage
    def render(recipient:, other_members:)
      GroupingMailer.encourage_match(
        recipient: recipient,
        other_members: other_members
      )
    end
  end
end
