class AddEditorIdToAnime < ActiveRecord::Migration
  def self.up
    add_column :animes, :editor_id, :integer
  end

  def self.down
    remove_column :animes, :editor_id
  end
end
