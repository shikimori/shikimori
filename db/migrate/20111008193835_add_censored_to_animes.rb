class AddCensoredToAnimes < ActiveRecord::Migration
  def self.up
    add_column :animes, :censored, :boolean, :default => false
  end

  def self.down
    remove_column :animes, :censored
  end
end
