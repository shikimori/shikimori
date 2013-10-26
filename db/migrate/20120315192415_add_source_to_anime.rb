class AddSourceToAnime < ActiveRecord::Migration
  def self.up
    add_column :animes, :source, :string
  end

  def self.down
    remove_column :animes, :source
  end
end
