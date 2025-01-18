class AddRelativeStrengthToOneRepMaxes < ActiveRecord::Migration[7.1]
  def change
    add_column :one_rep_maxes, :relative_strength, :float
  end
end
