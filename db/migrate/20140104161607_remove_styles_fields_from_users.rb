class RemoveStylesFieldsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :page_background
    remove_column :users, :page_border
    remove_column :users, :body_background
    remove_column :users, :smileys
    remove_column :users, :social
  end

  def down
    add_column :users, :page_background, :string
    add_column :users, :page_border, :boolean, default: false
    add_column :users, :body_background, :string
    add_column :users, :smileys, :boolean, default: true
    add_column :users, :social, :boolean, default: true
  end
end
