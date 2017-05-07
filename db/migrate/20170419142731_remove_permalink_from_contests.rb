class RemovePermalinkFromContests < ActiveRecord::Migration[5.0]
  def change
    remove_column :contests, :permalink
  end
end
