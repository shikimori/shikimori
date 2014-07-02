class RemoveNullableActionInEntries < ActiveRecord::Migration
  def up
    change_column :entries, :action, :string, null: true
  end

  def down
    change_column :entries, :action, :string, null: false
  end
end
