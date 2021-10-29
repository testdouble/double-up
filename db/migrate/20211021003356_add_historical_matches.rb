class AddHistoricalMatches < ActiveRecord::Migration[6.1]
  def change
    create_table :historical_matches do |t|
      t.string :members, array: true, default: []
      t.string :grouping
      t.date :matched_on

      t.timestamps
    end
  end
end
