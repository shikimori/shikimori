class RemoveHtmlBodyFromComments < ActiveRecord::Migration
  def change
    remove_column :comments, :html_body, :text
  end
end
