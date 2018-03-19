class DropUserChanges < ActiveRecord::Migration[5.1]
  def change
    drop_table :user_changes
  end
end
