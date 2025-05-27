# frozen_string_literal: true

class AddBurnoutMetricsToWorkoutRoutines < ActiveRecord::Migration[7.1]
  def change
    add_column :workout_routines, :acute_load, :integer
    add_column :workout_routines, :chronic_load, :integer
    add_column :workout_routines, :mood, :integer
    add_column :workout_routines, :sleep_quality, :integer
    add_column :workout_routines, :soreness, :integer
  end
end
