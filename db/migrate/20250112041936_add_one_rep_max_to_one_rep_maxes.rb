class AddOneRepMaxToOneRepMaxes < ActiveRecord::Migration[7.1]
  def change
    add_column :one_rep_maxes, :one_rep_max, :float
  end
end
