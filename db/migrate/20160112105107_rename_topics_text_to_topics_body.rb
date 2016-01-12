class RenameTopicsTextToTopicsBody < ActiveRecord::Migration
  def change
    rename_column :entries, :text, :body
  end
end
