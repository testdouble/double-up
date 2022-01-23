class GroupingMailer < ApplicationMailer
  def encourage_match(recipient:, mailer_params:)
    @recipient = recipient
    @channel = mailer_params.channel
    @grouping = mailer_params.grouping.titleize
    @other_members = mailer_params.other_members

    mail(
      to: recipient.email,
      reply_to: @other_members.map(&:email),
      subject: "#{@grouping} with #{@other_members.map(&:name).join(", ")}",
      content_type: "text/plain"
    )
  end
end
