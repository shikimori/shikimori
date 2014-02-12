class RemoveDetailsFromVideo < ActiveRecord::Migration
  def up
    remove_column :videos, :details
  end

  def down
    add_column :videos, :details, :text
  end
end
