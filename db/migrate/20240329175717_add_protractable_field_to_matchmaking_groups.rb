class AddProtractableFieldToMatchmakingGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :matchmaking_groups, :is_protractable, :boolean, default: false, null: false
  end
end
