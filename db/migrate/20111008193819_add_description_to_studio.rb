class AddDescriptionToStudio < ActiveRecord::Migration
  def self.up
    add_column :studios, :description, :text
    add_column :studios, :ani_db_description, :text
  end

  def self.down
    remove_column :studios, :ani_db_description
    remove_column :studios, :description
  end
end
