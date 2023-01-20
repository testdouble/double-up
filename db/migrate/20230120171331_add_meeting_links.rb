class AddMeetingLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :meeting_links do |t|
      t.belongs_to :user, index: true
      t.string :link_url
      t.string :link_text
    end
  end
end
