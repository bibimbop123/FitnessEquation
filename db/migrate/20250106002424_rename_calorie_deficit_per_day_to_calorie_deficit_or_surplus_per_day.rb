# frozen_string_literal: true

class RenameCalorieDeficitPerDayToCalorieDeficitOrSurplusPerDay < ActiveRecord::Migration[7.1]
  def change
    rename_column :snapshots, :calorie_deficit_per_day, :calorie_deficit_or_surplus_per_day
  end
end
