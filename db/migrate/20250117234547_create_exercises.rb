class CreateExercises < ActiveRecord::Migration[7.1]
  def change
    create_table :exercises do |t|
      t.string :name
      t.integer :reps
      t.integer :sets
      t.float :weight
      t.references :workout_routine, null: false, foreign_key: true

      t.timestamps
    end
  end
end
