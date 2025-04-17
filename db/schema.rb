# frozen_string_literal: true

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

ActiveRecord::Schema[7.1].define(version: 20_250_417_000_049) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'activities', force: :cascade do |t|
    t.string 'trackable_type'
    t.bigint 'trackable_id'
    t.string 'owner_type'
    t.bigint 'owner_id'
    t.string 'key'
    t.text 'parameters'
    t.string 'recipient_type'
    t.bigint 'recipient_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[owner_id owner_type], name: 'index_activities_on_owner_id_and_owner_type'
    t.index %w[owner_type owner_id], name: 'index_activities_on_owner'
    t.index %w[recipient_id recipient_type], name: 'index_activities_on_recipient_id_and_recipient_type'
    t.index %w[recipient_type recipient_id], name: 'index_activities_on_recipient'
    t.index %w[trackable_id trackable_type], name: 'index_activities_on_trackable_id_and_trackable_type'
    t.index %w[trackable_type trackable_id], name: 'index_activities_on_trackable'
  end

  create_table 'ahoy_events', force: :cascade do |t|
    t.bigint 'visit_id'
    t.bigint 'user_id'
    t.string 'name'
    t.jsonb 'properties'
    t.datetime 'time'
    t.index %w[name time], name: 'index_ahoy_events_on_name_and_time'
    t.index ['properties'], name: 'index_ahoy_events_on_properties', opclass: :jsonb_path_ops, using: :gin
    t.index ['user_id'], name: 'index_ahoy_events_on_user_id'
    t.index ['visit_id'], name: 'index_ahoy_events_on_visit_id'
  end

  create_table 'ahoy_visits', force: :cascade do |t|
    t.string 'visit_token'
    t.string 'visitor_token'
    t.bigint 'user_id'
    t.string 'ip'
    t.text 'user_agent'
    t.text 'referrer'
    t.string 'referring_domain'
    t.text 'landing_page'
    t.string 'browser'
    t.string 'os'
    t.string 'device_type'
    t.string 'country'
    t.string 'region'
    t.string 'city'
    t.float 'latitude'
    t.float 'longitude'
    t.string 'utm_source'
    t.string 'utm_medium'
    t.string 'utm_term'
    t.string 'utm_content'
    t.string 'utm_campaign'
    t.string 'app_version'
    t.string 'os_version'
    t.string 'platform'
    t.datetime 'started_at'
    t.index ['user_id'], name: 'index_ahoy_visits_on_user_id'
    t.index ['visit_token'], name: 'index_ahoy_visits_on_visit_token', unique: true
    t.index %w[visitor_token started_at], name: 'index_ahoy_visits_on_visitor_token_and_started_at'
  end

  create_table 'exercises', force: :cascade do |t|
    t.string 'name'
    t.integer 'reps'
    t.integer 'sets'
    t.float 'weight'
    t.bigint 'workout_routine_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['workout_routine_id'], name: 'index_exercises_on_workout_routine_id'
  end

  create_table 'one_rep_maxes', force: :cascade do |t|
    t.string 'exercise'
    t.float 'weight_lbs'
    t.integer 'reps'
    t.bigint 'user_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.float 'one_rep_max'
    t.float 'relative_strength'
    t.index ['user_id'], name: 'index_one_rep_maxes_on_user_id'
  end

  create_table 'snapshots', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.float 'height_cm'
    t.float 'weight_kg'
    t.string 'activity_level'
    t.float 'goal_weight_kg'
    t.integer 'predicted_time_weeks'
    t.integer 'calorie_deficit_or_surplus_per_day'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['user_id'], name: 'index_snapshots_on_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.date 'dob'
    t.string 'gender'
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  end

  create_table 'workout_routines', force: :cascade do |t|
    t.string 'name'
    t.bigint 'user_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'acute_load'
    t.integer 'chronic_load'
    t.integer 'mood'
    t.integer 'sleep_quality'
    t.integer 'soreness'
    t.index ['user_id'], name: 'index_workout_routines_on_user_id'
  end

  add_foreign_key 'exercises', 'workout_routines'
  add_foreign_key 'one_rep_maxes', 'users'
  add_foreign_key 'snapshots', 'users'
  add_foreign_key 'workout_routines', 'users'
end
