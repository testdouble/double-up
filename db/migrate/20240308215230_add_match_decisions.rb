class AddMatchDecisions < ActiveRecord::Migration[7.0]
  def change
    create_table :match_decisions do |t|
      t.string :decision, null: false
      t.string :decided_by, null: false
      t.jsonb :details, null: false, default: {}

      t.references :historical_match, null: false

      t.timestamps
    end
  end
end
