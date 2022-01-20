class GroupingMailer < ApplicationMailer
  def encourage_match(recipient:, other_members:)
    @recipient = recipient
    @other_members = other_members

    mail(
      to: recipient.email,
      reply_to: other_members.map(&:email),
      subject: "doing some work",
      content_type: "text/plain"
    )
  end
end
