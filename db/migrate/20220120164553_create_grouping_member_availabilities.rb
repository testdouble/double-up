class CreateGroupingMemberAvailabilities < ActiveRecord::Migration[6.1]
  def change
    create_table :grouping_member_availabilities do |t|
      t.string :grouping
      t.string :member_id
      t.integer :availability, default: 0

      t.timestamps
    end

    add_index :grouping_member_availabilities, [:grouping, :availability], name: "grouping_availability"
  end
end
