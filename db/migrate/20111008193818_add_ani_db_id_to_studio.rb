class AddAniDbIdToStudio < ActiveRecord::Migration
  def self.up
    add_column :studios, :ani_db_id, :integer, :null => true
    add_column :studios, :ani_db_name, :string, :null => true
  end

  def self.down
    remove_column :studios, :ani_db_id
    remove_column :studios, :ani_db_name
  end
end
