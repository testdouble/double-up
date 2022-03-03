class GroupingMailer < ApplicationMailer
  def encourage_match(recipient:, mailer_params:)
    @recipient = recipient
    @channel = mailer_params.channel
    @grouping = mailer_params.grouping.titleize
    @other_members = humanizes_match_members(mailer_params.other_members)

    mail(
      to: recipient.email,
      reply_to: mailer_params.other_members.map(&:email),
      subject: "#{@grouping} with #{@other_members}",
      content_type: "text/plain"
    )
  end

  private

  def humanizes_match_members(members)
    names = members.map(&:name)
    if names.size > 2
      all_except_last = names.take(names.size - 1).join(", ")
      "#{all_except_last} and #{names.last}"
    else
      names.join(" and ")
    end
  end
end
