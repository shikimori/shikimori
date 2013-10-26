class AddFieldsToAnime < ActiveRecord::Migration
  def self.up
    add_column :animes, :aired, :date
    add_column :animes, :released, :date
    add_column :animes, :status, :string
    add_column :animes, :rating, :string
  end

  def self.down
    remove_column :animes, :aired
    remove_column :animes, :released
    remove_column :animes, :status
    remove_column :animes, :rating
  end
end
