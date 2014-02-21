class AddIsVisibleToSections < ActiveRecord::Migration
  def change
    add_column :sections, :is_visible, :boolean
  end
end
