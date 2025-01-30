# frozen_string_literal: true

class AddGenderAndAgeToSnapshots < ActiveRecord::Migration[7.1]
  def change
    add_column :snapshots, :gender, :string
    add_column :snapshots, :dob, :date
  end
end
