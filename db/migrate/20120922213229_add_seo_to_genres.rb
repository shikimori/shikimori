class AddSeoToGenres < ActiveRecord::Migration
  def self.up
    add_column :genres, :seo, :integer, default: 99
  end

  def self.down
    remove_column :genres, :seo
  end
end
