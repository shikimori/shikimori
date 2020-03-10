class AddIsVisibleToStudios < ActiveRecord::Migration[5.2]
  def change
    add_column :studios, :is_visible, :boolean
    Studio.find_each do |studio|
      studio.update! is_visible: studio.real?
    end
    change_column :studios, :is_visible, :boolean, null: false
  end
end
