class CreateSlackUserProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :slack_user_profiles do |t|
      t.string :slack_user_id, null: false, index: {unique: true}
      t.string :name

      t.timestamps
    end
  end
end
