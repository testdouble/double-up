module Notify
  class RetrievesPendingNotifications
    def call(grouping:)
      PendingNotification.for_grouping(grouping)
    end
  end
end
