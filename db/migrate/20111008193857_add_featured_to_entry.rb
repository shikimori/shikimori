class AddFeaturedToEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :featured, :boolean, :default => false
  end

  def self.down
    remove_column :entries, :featured
  end
end
