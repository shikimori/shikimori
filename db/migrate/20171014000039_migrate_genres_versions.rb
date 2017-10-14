class MigrateGenresVersions < ActiveRecord::Migration[5.1]
  def up
    Version
      .where("item_diff -> 'genres' is not null")
      .update_all(type: Version.name)

    Version
      .where("item_diff -> 'genres' is not null")
      .each do |version|
        version.item_diff['genre_ids'] = version.item_diff['genres']
        version.item_diff.delete 'genres'
        version.save! validate: false
      end
  end

  def down
    Version
      .where("item_diff -> 'genre_ids' is not null")
      .update_all(type: 'Versions::GenresVersion')

    Version
      .where("item_diff -> 'genre_ids' is not null")
      .each do |version|
        version.item_diff['genres'] = version.item_diff['genre_ids']
        version.item_diff.delete 'genre_ids'
        version.save! validate: false
      end
  end
end
