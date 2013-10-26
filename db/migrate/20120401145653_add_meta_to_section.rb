
class AddMetaToSection < ActiveRecord::Migration
  def self.up
    add_column :sections, :meta_title, :string
    add_column :sections, :meta_keywords, :string
    add_column :sections, :meta_description, :string
  end

  def self.down
    remove_column :sections, :meta_description
    remove_column :sections, :meta_keywords
    remove_column :sections, :meta_title
  end
end
