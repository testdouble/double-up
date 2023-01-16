class AddStatusToHistoricalMatches < ActiveRecord::Migration[7.0]
  def change
    add_column :historical_matches, :status, :string, default: "scoreable"
  end
end
