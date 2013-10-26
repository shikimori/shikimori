class AddPageBorderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :page_border, :boolean, null: false, default: false
  end
end
