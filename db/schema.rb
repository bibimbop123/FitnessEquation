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

ActiveRecord::Schema[7.1].define(version: 2025_01_12_041936) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "one_rep_maxes", force: :cascade do |t|
    t.string "exercise"
    t.float "weight_lbs"
    t.integer "reps"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "one_rep_max"
    t.index ["user_id"], name: "index_one_rep_maxes_on_user_id"
  end

  create_table "snapshots", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.float "height_cm"
    t.float "weight_kg"
    t.string "activity_level"
    t.float "goal_weight_kg"
    t.integer "predicted_time_weeks"
    t.integer "calorie_deficit_or_surplus_per_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_snapshots_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "dob"
    t.string "gender"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "one_rep_maxes", "users"
  add_foreign_key "snapshots", "users"
end
