class AddIndexToAnimes < ActiveRecord::Migration
  def self.up
    add_index :animes, :kind
  end

  def self.down
    remove_index :animes, :kind
  end
end
