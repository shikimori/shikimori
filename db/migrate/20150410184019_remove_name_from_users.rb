class RemoveNameFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :name, :string, limit: 255
  end
end
