class AddPendingNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :pending_notifications do |t|
      t.string :strategy
      t.date :last_attempted_on
      t.references :historical_match

      t.timestamps
    end
  end
end
