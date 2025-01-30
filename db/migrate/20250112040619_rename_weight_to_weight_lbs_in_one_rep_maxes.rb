# frozen_string_literal: true

class RenameWeightToWeightLbsInOneRepMaxes < ActiveRecord::Migration[7.1]
  def change
    rename_column :one_rep_maxes, :weight, :weight_lbs
  end
end
