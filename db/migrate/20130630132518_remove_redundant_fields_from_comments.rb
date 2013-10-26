class RemoveRedundantFieldsFromComments < ActiveRecord::Migration
  def up
    remove_column :comments, :title
    remove_column :comments, :subject
    remove_column :comments, :parent_id
    remove_column :comments, :lft
    remove_column :comments, :rgt
  end

  def down
    add_column :comments, :title, :string, :default => ""
    add_column :comments, :subject, :string, :default => ""
    add_column :comments, :parent_id, :integer
    add_column :comments, :lft, :integer
    add_column :comments, :rgt, :integer
  end
end
