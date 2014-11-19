class AddParsedAtToManga < ActiveRecord::Migration
  def change
    add_column :mangas, :parsed_at, :datetime
  end
end
