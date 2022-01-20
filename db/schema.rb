# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_01_20_164553) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "grouping_member_availabilities", force: :cascade do |t|
    t.string "grouping"
    t.string "member_id"
    t.integer "availability", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["grouping", "availability"], name: "grouping_availability"
  end

  create_table "historical_matches", force: :cascade do |t|
    t.string "members", default: [], array: true
    t.string "grouping"
    t.date "matched_on"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
