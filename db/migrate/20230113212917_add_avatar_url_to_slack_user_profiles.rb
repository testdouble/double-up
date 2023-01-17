class AddAvatarUrlToSlackUserProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :slack_user_profiles, :avatar_url, :string
  end
end
