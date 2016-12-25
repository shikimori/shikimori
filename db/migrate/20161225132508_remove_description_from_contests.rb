class RemoveDescriptionFromContests < ActiveRecord::Migration
  def change
    remove_column :contests, :description
  end
end
