class RemoveWeightAndHeightFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :weight_kg, :float
    remove_column :users, :height_cm, :float
  end
end
