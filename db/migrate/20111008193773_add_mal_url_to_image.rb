class AddMalUrlToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :mal, :string
  end

  def self.down
    remove_column :images, :mal
  end
end
