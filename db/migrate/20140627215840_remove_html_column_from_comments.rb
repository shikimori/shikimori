class RemoveHtmlColumnFromComments < ActiveRecord::Migration
  def change
    remove_column :comments, :html, :boolean, default: false
  end
end
