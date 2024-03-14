class AddReasonToPendingNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :pending_notifications, :reason, :string
  end
end
