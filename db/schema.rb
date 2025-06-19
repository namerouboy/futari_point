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

ActiveRecord::Schema[8.0].define(version: 2025_06_11_124111) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "point_card_id", null: false
    t.string "content", null: false
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_card_id"], name: "index_notifications_on_point_card_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "point_cards", force: :cascade do |t|
    t.bigint "giver_id", null: false
    t.bigint "receiver_id"
    t.string "title", null: false
    t.text "message"
    t.string "pin_code"
    t.integer "max_point", default: 20, null: false
    t.integer "current_round", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["giver_id"], name: "index_point_cards_on_giver_id"
    t.index ["receiver_id"], name: "index_point_cards_on_receiver_id"
  end

  create_table "point_records", force: :cascade do |t|
    t.bigint "point_card_id", null: false
    t.bigint "added_by_user_id", null: false
    t.integer "points", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["added_by_user_id"], name: "index_point_records_on_added_by_user_id"
    t.index ["point_card_id"], name: "index_point_records_on_point_card_id"
  end

  create_table "rewards", force: :cascade do |t|
    t.bigint "point_card_id", null: false
    t.string "name", null: false
    t.integer "required_points", null: false
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_card_id"], name: "index_rewards_on_point_card_id"
  end

  create_table "special_days", force: :cascade do |t|
    t.bigint "point_card_id", null: false
    t.integer "date", null: false
    t.integer "multiplier", default: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_card_id"], name: "index_special_days_on_point_card_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "notifications", "point_cards"
  add_foreign_key "notifications", "users"
  add_foreign_key "point_cards", "users", column: "giver_id"
  add_foreign_key "point_cards", "users", column: "receiver_id"
  add_foreign_key "point_records", "point_cards"
  add_foreign_key "point_records", "users", column: "added_by_user_id"
  add_foreign_key "rewards", "point_cards"
  add_foreign_key "special_days", "point_cards"
end
