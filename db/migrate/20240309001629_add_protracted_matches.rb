class AddProtractedMatches < ActiveRecord::Migration[7.0]
  def change
    create_table :protracted_matches do |t|
      t.string :protracted_by, null: false
      t.string :completed_by
      t.datetime :completed_at
      t.references :historical_match, null: false, index: true
      t.timestamps
    end
  end
end
