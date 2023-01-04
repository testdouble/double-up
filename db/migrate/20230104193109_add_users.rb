class AddUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :slack_user_id, null: false, index: {unique: true}
      t.string :auth_token
      t.datetime :auth_token_expires_at

      t.timestamps
    end
  end
end
