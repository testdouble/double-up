class HistoricalMatch < ApplicationRecord
  enum status: {scoreable: "scoreable", archived: "archived"}

  has_many :pending_notifications, dependent: :nullify
  has_one :protracted_match, dependent: :destroy

  validates :matched_on, :grouping, presence: true
  validate :at_least_two_members

  scope :in_grouping, ->(grouping) { where(grouping: grouping) }
  scope :with_member, ->(member) { where("members @> ?", "{#{member}}") }
  scope :older_than, ->(date) { where("created_at::date < '#{date.to_date}'") }
  scope :for_user, ->(user) { with_member(user.slack_user_id) }

  delegate :protract!, to: :protracted_match, allow_nil: true
  delegate :complete!, to: :protracted_match, allow_nil: true

  def self.protracted_in(grouping)
    find_by_sql([<<~SQL.squish, grouping])
      with protracted_matches as (
        select
          hm.*,
          row_number() over (partition by unnest(hm.members) order by hm.matched_on desc) as rn
        from historical_matches hm
        inner join protracted_matches pm ON hm.id = pm.historical_match_id and pm.completed_at is null
        where hm.grouping = ?
      ), most_recent_protracted as (
        select distinct on (id) *
        from protracted_matches
        where rn = 1
      )
      select * from most_recent_protracted
    SQL
  end

  private

  def at_least_two_members
    if !members.is_a?(Array) || members.size < 2
      errors.add(:members, "must include multiple members")
    end
  end
end
