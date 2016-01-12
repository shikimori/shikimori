class MigrateNewsToSingleType < ActiveRecord::Migration
  def change
    Entry
      .where(type: ['AnimeNews', 'MangaNews', 'SiteNews'])
      .update_all(type: 'Topics::NewsTopic')
  end
end
