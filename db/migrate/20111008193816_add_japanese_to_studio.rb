class AddJapaneseToStudio < ActiveRecord::Migration
  def self.up
    add_column :studios, :japanese, :string, :null => false, :default => ''
  end

  def self.down
    remove_column :studios, :japanese
  end
end
