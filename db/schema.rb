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

ActiveRecord::Schema[7.0].define(version: 2023_09_27_185507) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calendar_links", force: :cascade do |t|
    t.bigint "user_id"
    t.string "link_name"
    t.string "link_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_calendar_links_on_user_id"
  end

  create_table "historical_matches", force: :cascade do |t|
    t.string "members", default: [], array: true
    t.string "grouping"
    t.date "matched_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "scoreable"
    t.index ["members"], name: "index_historical_matches_on_members", using: :gin
  end

  create_table "matchmaking_groups", force: :cascade do |t|
    t.string "name", null: false
    t.string "slack_channel_name", null: false
    t.string "schedule", null: false
    t.integer "target_size", null: false
    t.boolean "is_active", default: false, null: false
    t.string "slack_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pending_notifications", force: :cascade do |t|
    t.string "strategy"
    t.date "last_attempted_on"
    t.bigint "historical_match_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["historical_match_id"], name: "index_pending_notifications_on_historical_match_id"
  end

  create_table "slack_user_profiles", force: :cascade do |t|
    t.string "slack_user_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar_url"
    t.index ["slack_user_id"], name: "index_slack_user_profiles_on_slack_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "slack_user_id", null: false
    t.string "auth_token"
    t.datetime "auth_token_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slack_user_id"], name: "index_users_on_slack_user_id", unique: true
  end

end
