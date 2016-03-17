class RenameOfftopicToIsOfftopicInComments < ActiveRecord::Migration
  def change
    rename_column :comments, :offtopic, :is_offtopic
  end
end
