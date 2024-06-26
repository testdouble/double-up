module Rakes
  class SendPendingNotifications
    def initialize(stdout:, stderr:)
      @stdout = stdout
      @stderr = stderr

      @collect_groups = CollectGroups.new
      @retrieves_pending_notifications = Notify::RetrievesPendingNotifications.new
      @determines_retriability = Notify::DeterminesRetriability.new
      @use_email_to_deliver_notification = Notify::UseEmailToDeliverNotification.new
      @use_slack_to_deliver_notification = Notify::UseSlackToDeliverNotification.new
    end

    def call
      @collect_groups.call.each do |group|
        notifications = @retrieves_pending_notifications.call(grouping: group.name)

        if notifications.empty?
          @stdout.puts "No pending notifications found for '#{group.name}'"
          next
        end

        notifications.each do |notification|
          @stdout.puts "Sending #{notification.reason} notification for '#{group.name}'"

          if sendable_today?(group, notification)
            notification_strategy = pick_strategy(notification)
            notification_strategy&.call(notification, group)
          end

          notification.delete
          @stdout.puts "#{notification.strategy.titleize} notification sent"
        end
      end
    end

    private

    def sendable_today?(group, notification)
      @determines_retriability.can_retry?(group.schedule, original_date: notification.created_at.to_date)
    end

    def pick_strategy(notification)
      return @use_email_to_deliver_notification if notification.use_email?
      @use_slack_to_deliver_notification if notification.use_slack?
    end
  end
end
