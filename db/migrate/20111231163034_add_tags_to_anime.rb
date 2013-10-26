class AddTagsToAnime < ActiveRecord::Migration
  def self.up
    add_column :animes, :tags, :string
    add_column :mangas, :tags, :string

    ['animes', 'mangas'].each do |kind|
      ActiveRecord::Base.connection.execute("update #{kind} set tags = replace(replace(name, '\\'', ''), ' ', '_')")
    end
  end

  def self.down
    remove_column :animes, :tags
    remove_column :mangas, :tags
  end
end
