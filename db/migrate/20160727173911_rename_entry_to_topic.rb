class RenameEntryToTopic < ActiveRecord::Migration
  def change
    rename_table :entries, :topics
  end
end
