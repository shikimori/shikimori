class RemovePermalinkFromClubs < ActiveRecord::Migration
  def change
    remove_column :clubs, :permalink
  end
end
