class AddProtractedMatches < ActiveRecord::Migration[7.0]
  def change
    create_table :protracted_matches do |t|
      t.string :last_protracted_by
      t.string :completed_by
      t.datetime :completed_at
      t.references :historical_match, null: false, index: true
      t.timestamps
    end
  end
end
