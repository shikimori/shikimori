class RemoveDescriptionFromContests < ActiveRecord::Migration[5.2]
  def change
    remove_column :contests, :description
  end
end
