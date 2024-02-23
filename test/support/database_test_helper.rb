module DatabaseTestHelper
  def create_historical_match(grouping:, members:, pending_notifications: [])
    HistoricalMatch.create(
      grouping: grouping,
      members: members,
      matched_on: Date.today,
      pending_notifications: pending_notifications
    )
  end

  def create_matchmaking_group(name:, **attrs)
    default_attrs = {
      slack_channel_name: "test-channel",
      schedule: "daily",
      target_size: 2,
      is_active: true,
      slack_user_id: "42"
    }

    MatchmakingGroup.create(default_attrs.merge(attrs).merge(name: name))
  end

  def create_user(attrs = {})
    slack_user_id = attrs[:slack_user_id] || "USER"
    SlackUserProfile.create(slack_user_id: slack_user_id)

    User.create(
      auth_token: attrs[:auth_token] || SecureRandom.uuid,
      auth_token_expires_at: attrs[:auth_token_expires_at] || 1.day.from_now,
      slack_user_id: slack_user_id
    )
  end

  def create_pending_email_notification
    PendingNotification.create(strategy: "email")
  end

  def create_pending_slack_notification
    PendingNotification.create(strategy: "slack")
  end
end
