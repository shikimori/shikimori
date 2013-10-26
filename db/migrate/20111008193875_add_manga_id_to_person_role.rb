class AddMangaIdToPersonRole < ActiveRecord::Migration
  def self.up
    add_column :person_roles, :manga_id, :integer
  end

  def self.down
    remove_column :person_roles, :manga_id
  end
end
