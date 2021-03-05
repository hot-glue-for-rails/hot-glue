# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_01_100504) do

  create_table "browsers", force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_browsers_on_name"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "utm_source", limit: 256
    t.string "utm_campaign", limit: 256
    t.string "utm_medium", limit: 256
    t.string "utm_content", limit: 256
    t.string "utm_term", limit: 256
    t.string "sha1", limit: 40
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["sha1"], name: "index_campaigns_on_sha1"
  end

  create_table "data_migrations", force: :cascade do |t|
    t.string "version"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "visits", force: :cascade do |t|
    t.datetime "first_pageload"
    t.datetime "last_pageload"
    t.integer "original_visit_id"
    t.integer "campaign_id"
    t.integer "browser_id"
    t.string "ip_v4_address", limit: 15
    t.integer "viewport_width"
    t.integer "viewport_height"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
