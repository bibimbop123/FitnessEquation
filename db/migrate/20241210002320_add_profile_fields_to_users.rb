class AddProfileFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :gender, :string
    add_column :users, :activity_level, :string
    add_column :users, :birthday, :date
  end
end
