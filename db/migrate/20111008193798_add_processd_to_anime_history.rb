class AddProcessdToAnimeHistory < ActiveRecord::Migration
  def self.up
    add_column :anime_histories, :processed, :boolean, :default => false
  end

  def self.down
    remove_column :anime_histories, :processed
  end
end
