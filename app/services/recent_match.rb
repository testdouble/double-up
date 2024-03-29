class RecentMatch < Struct.new(
  :match_id, :slack_user_id, :grouping, :matched_on, :other_members, :match_status,
  keyword_init: true
)
  def scoreable?
    match_status == "scoreable"
  end
end
