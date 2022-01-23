class GroupingMailer < ApplicationMailer
  def encourage_match(recipient:, mailer_params:)
    @recipient = recipient
    @channel = mailer_params.channel
    @grouping = mailer_params.grouping
    @other_members = mailer_params.other_members

    mail(
      to: recipient.email,
      reply_to: @other_members.map(&:email),
      subject: "doing some work",
      content_type: "text/plain"
    )
  end
end
