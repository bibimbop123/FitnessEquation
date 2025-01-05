class RemoveDobAndGenderFromSnapshots < ActiveRecord::Migration[7.1]
  def change
    remove_column :snapshots, :dob, :date
    remove_column :snapshots, :gender, :string
  end
end
