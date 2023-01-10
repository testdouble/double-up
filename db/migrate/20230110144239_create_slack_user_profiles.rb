class CreateSlackUserProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :slack_user_profiles do |t|
      t.string :user_id
      t.string :name

      t.timestamps
    end
  end
end
