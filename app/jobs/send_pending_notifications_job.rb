class SendPendingNotificationsJob
  def initialize(config: nil)
    @retrieves_pending_notifications = Notify::RetrievesPendingNotifications.new
    @notifies_grouping_members = NotifiesGroupingMembers.new

    @config = config || Rails.application.config.x.matchmaking
  end

  def perform(grouping:)
    pending_notifications = @retrieves_pending_notifications.call(grouping: grouping)

    pending_notifications.each do |notification|
      notification.delete
    end
  end
end
