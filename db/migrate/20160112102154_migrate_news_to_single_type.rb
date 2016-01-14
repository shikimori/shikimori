class MigrateNewsToSingleType < ActiveRecord::Migration
  def up
    Entry
      .where(type: ['AnimeNews', 'MangaNews', 'SiteNews'])
      .update_all(type: 'Topics::NewsTopic')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
