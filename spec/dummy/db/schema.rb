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

ActiveRecord::Schema.define(version: 2022_02_01_165048) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # These are custom enum types that must be created before they can be used in the schema definition
  create_enum "genres", ["Fiction", "Nonfiction", "Mystery", "Romance", "Novel"]

  create_table "abcs", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cantelopes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "dfgs", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "cantelope_id"
  end

  create_table "ghis", force: :cascade do |t|
    t.integer "dfg_id"
    t.integer "xyz_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "hgis", force: :cascade do |t|
    t.string "name"
    t.integer "how_many"
    t.text "hello"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "jkls", force: :cascade do |t|
    t.integer "hgi_id"
    t.string "name"
    t.string "blurb"
    t.text "long_description"
    t.float "cost"
    t.integer "how_many_printed"
    t.datetime "approved_at"
    t.date "release_on"
    t.time "time_of_day"
    t.boolean "selected"
    t.enum "genre", as: "genres"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "xyzs", force: :cascade do |t|
    t.integer "nothing_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
