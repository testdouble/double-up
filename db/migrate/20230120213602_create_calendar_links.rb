class CreateCalendarLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :calendar_links do |t|
      t.belongs_to :user, index: true
      t.string :link_name
      t.string :link_url

      t.timestamps
    end
  end
end
