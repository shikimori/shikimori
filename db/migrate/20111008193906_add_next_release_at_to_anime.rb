class AddNextReleaseAtToAnime < ActiveRecord::Migration
  def self.up
    add_column :animes, :next_release_at, :datetime
  end

  def self.down
    remove_column :animes, :next_release_at
  end
end
