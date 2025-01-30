# frozen_string_literal: true

class CreateSnapshots < ActiveRecord::Migration[7.1]
  def change
    create_table :snapshots do |t|
      t.references :user, null: false, foreign_key: true
      t.float :height_cm
      t.float :weight_kg
      t.string :activity_level
      t.float :goal_weight_kg
      t.integer :predicted_time_weeks
      t.integer :calorie_deficit_per_day

      t.timestamps
    end
  end
end
