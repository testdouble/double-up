class AddMatchmakingGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :matchmaking_groups do |t|
      t.string :name, null: false
      t.string :slack_channel_name, null: false
      t.string :schedule, null: false
      t.integer :target_size, null: false
      t.boolean :is_active, null: false, default: false
      t.string :slack_user_id, null: false

      t.timestamps
    end
  end
end
