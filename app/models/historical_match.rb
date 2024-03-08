class HistoricalMatch < ApplicationRecord
  enum status: {scoreable: "scoreable", archived: "archived"}

  has_many :match_decisions, dependent: :destroy
  has_many :pending_notifications, dependent: :nullify

  validates :matched_on, :grouping, presence: true
  validate :at_least_two_members

  scope :in_grouping, ->(grouping) { where(grouping: grouping) }
  scope :with_member, ->(member) { where("members @> ?", "{#{member}}") }
  scope :older_than, ->(date) { where("created_at::date < '#{date.to_date}'") }
  scope :for_user, ->(user) { with_member(user.slack_user_id) }

  def self.most_recent_by_member(grouping, members = [])
    matches = in_grouping(grouping).find_by_sql([<<~SQL.squish, grouping])
      with ordered_matches as (
        select
          historical_matches.*,
          unnest(historical_matches.members) as member,
          row_number() over (partition by unnest(historical_matches.members) order by matched_on desc) as rn
        from historical_matches
        where grouping = ?
      ), most_recent_matches as (
        select * from ordered_matches where rn = 1
      )
      select * from most_recent_matches
    SQL

    matches.each_with_object({}) do |match, memo|
      match.members.each do |member|
        next memo if members.any? && members.exclude?(member)
        memo[member] ||= match
      end
    end
  end

  private

  def at_least_two_members
    if !members.is_a?(Array) || members.size < 2
      errors.add(:members, "must include multiple members")
    end
  end
end
