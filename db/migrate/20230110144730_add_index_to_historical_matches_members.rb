class AddIndexToHistoricalMatchesMembers < ActiveRecord::Migration[7.0]
  def change
    add_index :historical_matches, :members, if_not_exists: true
  end
end
