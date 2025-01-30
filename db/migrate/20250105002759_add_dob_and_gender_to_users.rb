# frozen_string_literal: true

class AddDobAndGenderToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :dob, :date
    add_column :users, :gender, :string
  end
end
