module Rakes
  class SendsPendingNotifications
    def initialize(stdout:, stderr:, config: nil)
      @stdout = stdout
      @stderr = stderr
      @config = config || Rails.application.config.x.matchmaking

      @retrieves_pending_notifications = Notify::RetrievesPendingNotifications.new
      @determines_retriability = Notify::DeterminesRetriability.new
      @uses_email_to_deliver_notification = Notify::UsesEmailToDeliverNotification.new
      @uses_slack_to_deliver_notification = Notify::UsesSlackToDeliverNotification.new
    end

    def call
      @config.each_pair do |grouping, grouping_config|
        notifications = @retrieves_pending_notifications.call(grouping: grouping)

        if notifications.empty?
          @stdout.puts "No pending notifications found for '#{grouping}'"
          next
        end

        notifications.each do |notification|
          @stdout.puts "Sending notifications for '#{grouping}'"

          if sendable_today?(grouping_config, notification)
            notification_strategy = pick_strategy(notification)
            notification_strategy&.call(notification: notification)
          end

          notification.delete
          @stdout.puts "#{notification.strategy.titleize} notification sent"
        end
      end
    end

    private

    def sendable_today?(grouping_config, notification)
      @determines_retriability.can_retry?(grouping_config.schedule, original_date: notification.created_at.to_date)
    end

    def pick_strategy(notification)
      return @uses_email_to_deliver_notification if notification.use_email?
      @uses_slack_to_deliver_notification if notification.use_slack?
    end
  end
end
