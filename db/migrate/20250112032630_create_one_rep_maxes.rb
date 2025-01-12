class CreateOneRepMaxes < ActiveRecord::Migration[7.1]
  def change
    create_table :one_rep_maxes do |t|
      t.string :exercise
      t.float :weight
      t.integer :reps
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
